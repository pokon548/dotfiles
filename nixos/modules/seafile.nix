{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/mnt/external-storage/seafile";
  pod-name = "seafile";
  open-ports = [ "127.0.0.1:8088:80" "127.0.0.1:46732:8080" ];
  seafile-ver = "11.0.2";
  mariadb-ver = "10.11";
  memcached-ver = "1.6.18";
in
{
  sops = {
    defaultSopsFile = lib.mkForce ../../secrets/hetzner.yaml;
    secrets = {
      "seafile/email" = { };
      "seafile/password" = { };
      "seafile/db-pass" = { };
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
}
