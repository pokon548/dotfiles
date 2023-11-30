{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/mnt/external-storage/seafile";
  pod-name = "seafile";
  open-ports = [ "127.0.0.1:8088:80" "127.0.0.1:46732:8080" ];
  seafile-ver = "11.0.2";
  mariadb-ver = "10.11";
  memcached-ver = "1.6.18";
  perserve-backups = 92;
in
{
  sops = {
    defaultSopsFile = lib.mkForce ../../secrets/hetzner.yaml;
    secrets = {
      "seafile/email" = { };
      "seafile/password" = { };
      "seafile/db-pass" = { };
      "seafile/seafile-pass" = { };

      "b2/seafile-data/bucket" = { };
      "b2/seafile-data/appid" = { };
      "b2/seafile-data/appkey" = { };
      "b2/seafile-data/repo-password" = { };

      "b2/seafile-db/bucket" = { };
      "b2/seafile-db/appid" = { };
      "b2/seafile-db/appkey" = { };
      "b2/seafile-db/repo-password" = { };

      "storj/seafile-data/bucket" = { };
      "storj/seafile-data/keyid" = { };
      "storj/seafile-data/accesskey" = { };
      "storj/seafile-data/repo-password" = { };

      "storj/seafile-db/bucket" = { };
      "storj/seafile-db/keyid" = { };
      "storj/seafile-db/accesskey" = { };
      "storj/seafile-db/repo-password" = { };

      "ntfy-token" = { };
    };
    templates = {
      "seafile-db-env".content = ''
        MYSQL_LOG_CONSOLE=true
        MYSQL_ROOT_PASSWORD=${config.sops.placeholder."seafile/db-pass"}
      '';
      "seafile-admin-env".content = ''
        DB_HOST=seafile-db
        DB_ROOT_PASSWD=${config.sops.placeholder."seafile/db-pass"}
        TIME_ZONE=Asia/Shanghai
        SEAFILE_ADMIN_EMAIL=${config.sops.placeholder."seafile/email"}
        SEAFILE_ADMIN_PASSWORD=${config.sops.placeholder."seafile/password"}
        SEAFILE_SERVER_HOSTNAME=cloud-next.bukn.uk
      '';
      "restic-b2-data-env".content = ''
        B2_ACCOUNT_ID=${config.sops.placeholder."b2/seafile-data/appid"}
        B2_ACCOUNT_KEY=${config.sops.placeholder."b2/seafile-data/appkey"}
      '';
      "restic-b2-db-env".content = ''
        B2_ACCOUNT_ID=${config.sops.placeholder."b2/seafile-db/appid"}
        B2_ACCOUNT_KEY=${config.sops.placeholder."b2/seafile-db/appkey"}
      '';
      "restic-storj-data-env".content = ''
        AWS_ACCESS_KEY_ID=${config.sops.placeholder."storj/seafile-data/keyid"}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."storj/seafile-data/accesskey"}
      '';
      "restic-storj-db-env".content = ''
        AWS_ACCESS_KEY_ID=${config.sops.placeholder."storj/seafile-db/keyid"}
        AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."storj/seafile-db/accesskey"}
      '';
    };
  };

  virtualisation.oci-containers.containers.seafile-server = {
    autoStart = true;
    dependsOn = [ "seafile-db" "memcached" ];
    environmentFiles = [ config.sops.templates."seafile-admin-env".path ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/seafileltd/seafile-mc:${seafile-ver}";
    volumes = [ "${nas-path}/server-data:/shared" ];
    user = "root:root";
  };

  virtualisation.oci-containers.containers.seafile-db = {
    autoStart = true;
    environmentFiles = [ config.sops.templates."seafile-db-env".path ];
    extraOptions = [ "--pod=seafile" "--security-opt=seccomp=unconfined" ];
    image = "docker.io/mariadb:${mariadb-ver}";
    volumes = [
      "db:/var/lib/mysql"
    ];
  };

  virtualisation.oci-containers.containers.memcached = {
    autoStart = true;
    cmd = [ "memcached" "-m 512" ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/memcached:${memcached-ver}";
  };

  systemd.services."podman-create-${pod-name}" =
    let
      portsMapping = lib.concatMapStrings (port: " -p " + port) open-ports;
      start = pkgs.writeShellScript "create-pod" ''
        podman pod exists ${pod-name} || podman pod create -n ${pod-name} ${portsMapping}
        exit 0
      '';
    in
    rec {
      path = [ pkgs.coreutils config.virtualisation.podman.package ];
      before = [
        "${backend}-seafile-server.service"
        "${backend}-seafile-db.service"
        "${backend}-memcached.service"
      ];
      requiredBy = before;
      partOf = before;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = start;
      };
    };

  services.restic.backups = {
    seafile-data-b2 = {
      environmentFile = config.sops.templates."restic-b2-data-env".path;
      repositoryFile = config.sops.secrets."b2/seafile-data/bucket".path;
      passwordFile = config.sops.secrets."b2/seafile-data/repo-password".path;
      paths = [ "${nas-path}" ];
      initialize = true;
      timerConfig = {
        OnCalendar = "02:00";
        Persistent = true;
      };
      pruneOpts = [ "--keep-last ${toString perserve-backups}" ];
      backupPrepareCommand = ''
        NTFY_TOKEN=$(cat ${config.sops.secrets."ntfy-token".path})

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -H "Title: [Seafile] 正在备份文件到 B2 可用区..." \
        -d "这可能需要很长时间..." \
        https://ntfy.bukn.uk/backup-notice

        unset NTFY_TOKEN
      '';
      backupCleanupCommand = ''
        NTFY_TOKEN=$(cat ${config.sops.secrets."ntfy-token".path})

        journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value restic-backups-seafile-data-b2.service` > /tmp/restic-backups-seafile-data.log

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -H "Title: [Seafile] 文件备份完毕。区域：B2" \
        -d "请参考运行日志，确认备份是否顺利完成" \
        https://ntfy.bukn.uk/backup-notice

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -T /tmp/restic-backups-seafile-data.log \
        -H "Filename: restic-backups-seafile-data.log" \
        https://ntfy.bukn.uk/backup-notice

        unset NTFY_TOKEN

        rm -r /tmp/restic-backups-seafile-data.log
      '';
    };
    seafile-db-b2 = {
      environmentFile = config.sops.templates."restic-b2-db-env".path;
      repositoryFile = config.sops.secrets."b2/seafile-db/bucket".path;
      passwordFile = config.sops.secrets."b2/seafile-db/repo-password".path;
      paths = [ "/tmp/seafile-db-backup" ];
      initialize = true;
      pruneOpts = [ "--keep-last ${toString perserve-backups}" ];
      backupPrepareCommand = ''
        TIME=$(date +"%Y-%m-%d-%H-%M-%S")
        NTFY_TOKEN=$(cat ${config.sops.secrets."ntfy-token".path})
        DB_PASSWORD=$(cat ${config.sops.secrets."seafile/seafile-pass".path})

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -H "Title: [Seafile] 正在备份数据库到 B2 可用区..." \
        -d "这应该不需要太多时间... 吧？" \
        https://ntfy.bukn.uk/backup-notice

        unset NTFY_TOKEN

        mkdir -pv /tmp/seafile-db-backup

        ${pkgs.podman}/bin/podman exec -it seafile-db mysqldump -useafile -p$DB_PASSWORD -hseafile-db --opt ccnet_db > /tmp/seafile-db-backup/ccnet.sql.$TIME
        ${pkgs.podman}/bin/podman exec -it seafile-db mysqldump -useafile -p$DB_PASSWORD -hseafile-db --opt seafile_db > /tmp/seafile-db-backup/seafile.sql.$TIME
        ${pkgs.podman}/bin/podman exec -it seafile-db mysqldump -useafile -p$DB_PASSWORD -hseafile-db --opt seahub_db > /tmp/seafile-db-backup/seahub.sql.$TIME

        unset DB_PASSWORD
        echo "Done"
      '';
      backupCleanupCommand = ''
        NTFY_TOKEN=$(cat ${config.sops.secrets."ntfy-token".path})

        journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value restic-backups-seafile-db-b2.service` > /tmp/restic-backups-seafile-db.log

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -H "Title: [Seafile] 数据库备份完毕。区域：B2" \
        -d "请参考运行日志，确认备份是否顺利完成" \
        https://ntfy.bukn.uk/backup-notice

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -T /tmp/restic-backups-seafile-db.log \
        -H "Filename: restic-backups-seafile-db.log" \
        https://ntfy.bukn.uk/backup-notice

        unset NTFY_TOKEN

        rm -r /tmp/restic-backups-seafile-db.log
        rm -r /tmp/seafile-db-backup
      '';
      timerConfig = {
        OnCalendar = "01:55";
        Persistent = true;
      };
    };
    seafile-data-storj = {
      environmentFile = config.sops.templates."restic-storj-data-env".path;
      repositoryFile = config.sops.secrets."storj/seafile-data/bucket".path;
      passwordFile = config.sops.secrets."storj/seafile-data/repo-password".path;
      paths = [ "${nas-path}" ];
      initialize = true;
      timerConfig = {
        OnCalendar = "03:00";
        Persistent = true;
      };
      pruneOpts = [ "--keep-last ${toString perserve-backups}" ];
      backupPrepareCommand = ''
        NTFY_TOKEN=$(cat ${config.sops.secrets."ntfy-token".path})

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -H "Title: [Seafile] 正在备份文件到 Storj 可用区..." \
        -d "这可能需要很长时间..." \
        https://ntfy.bukn.uk/backup-notice

        unset NTFY_TOKEN
      '';
      backupCleanupCommand = ''
        NTFY_TOKEN=$(cat ${config.sops.secrets."ntfy-token".path})

        journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value restic-backups-seafile-data-storj.service` > /tmp/restic-backups-seafile-data.log

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -H "Title: [Seafile] 文件备份完毕。区域：Storj" \
        -d "请参考运行日志，确认备份是否顺利完成" \
        https://ntfy.bukn.uk/backup-notice

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -T /tmp/restic-backups-seafile-data.log \
        -H "Filename: restic-backups-seafile-data.log" \
        https://ntfy.bukn.uk/backup-notice

        unset NTFY_TOKEN

        rm -r /tmp/restic-backups-seafile-data.log
      '';
    };
    seafile-db-storj = {
      environmentFile = config.sops.templates."restic-storj-db-env".path;
      repositoryFile = config.sops.secrets."storj/seafile-db/bucket".path;
      passwordFile = config.sops.secrets."storj/seafile-db/repo-password".path;
      paths = [ "/tmp/seafile-db-backup" ];
      initialize = true;
      pruneOpts = [ "--keep-last ${toString perserve-backups}" ];
      backupPrepareCommand = ''
        TIME=$(date +"%Y-%m-%d-%H-%M-%S")
        NTFY_TOKEN=$(cat ${config.sops.secrets."ntfy-token".path})
        DB_PASSWORD=$(cat ${config.sops.secrets."seafile/seafile-pass".path})

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -H "Title: [Seafile] 正在备份数据库到 Storj 可用区..." \
        -d "这应该不需要太多时间... 吧？" \
        https://ntfy.bukn.uk/backup-notice

        unset NTFY_TOKEN

        mkdir -pv /tmp/seafile-db-backup

        ${pkgs.podman}/bin/podman exec -it seafile-db mysqldump -useafile -p$DB_PASSWORD -hseafile-db --opt ccnet_db > /tmp/seafile-db-backup/ccnet.sql.$TIME
        ${pkgs.podman}/bin/podman exec -it seafile-db mysqldump -useafile -p$DB_PASSWORD -hseafile-db --opt seafile_db > /tmp/seafile-db-backup/seafile.sql.$TIME
        ${pkgs.podman}/bin/podman exec -it seafile-db mysqldump -useafile -p$DB_PASSWORD -hseafile-db --opt seahub_db > /tmp/seafile-db-backup/seahub.sql.$TIME

        unset DB_PASSWORD
        echo "Done"
      '';
      backupCleanupCommand = ''
        NTFY_TOKEN=$(cat ${config.sops.secrets."ntfy-token".path})

        journalctl _SYSTEMD_INVOCATION_ID=`systemctl show -p InvocationID --value restic-backups-seafile-db-storj.service` > /tmp/restic-backups-seafile-db.log

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -H "Title: [Seafile] 数据库备份完毕。区域：Storj" \
        -d "请参考运行日志，确认备份是否顺利完成" \
        https://ntfy.bukn.uk/backup-notice

        ${pkgs.curl}/bin/curl \
        -u $NTFY_TOKEN \
        -T /tmp/restic-backups-seafile-db.log \
        -H "Filename: restic-backups-seafile-db.log" \
        https://ntfy.bukn.uk/backup-notice

        unset NTFY_TOKEN

        rm -r /tmp/restic-backups-seafile-db.log
        rm -r /tmp/seafile-db-backup
      '';
      timerConfig = {
        OnCalendar = "02:55";
        Persistent = true;
      };
    };
  };
}
