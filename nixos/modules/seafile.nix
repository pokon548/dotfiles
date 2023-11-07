{ config, lib, pkgs, ... }:
let
  backend = config.virtualisation.oci-containers.backend;
  nas-path = "/mnt/external-storage/seafile";
  pod-name = "seafile";
  open-ports = [ "127.0.0.1:8088:80" ];
  seafile-ver = "10.0.1";
  mariadb-ver = "10.11.4";
  memcached-ver = "1.6.21";
  caddy-ver = "2.7.5";
  seahub-media-caddyfile = pkgs.writeText "Caddyfile" ''
    {
        admin off
        http_port 8098
        https_port 8099
    }
    :8098 {
        root * /usr/share/caddy
        file_server
    }
  '';
  seafile-caddy-caddyfile = pkgs.writeText "Caddyfile" ''
    {
        auto_https disable_redirects
    }

    http:// https:// {
        reverse_proxy seahub:8000 {
            lb_policy header X-Forwarded-For
            trusted_proxies private_ranges
        }
        reverse_proxy /seafdav* seafile-server:8080 {
            header_up Destination https:// http://
            trusted_proxies private_ranges
        }
        handle_path /seafhttp* {
            uri strip_prefix seafhttp
            reverse_proxy seafile-server:8082 {
                trusted_proxies private_ranges
            }
        }
        handle_path /notification* {
            uri strip_prefix notification
            reverse_proxy seafile-server:8083 {
                trusted_proxies private_ranges
            }
        }
        reverse_proxy /media/* seahub-media:8098 {
            lb_policy header X-Forwarded-For
            trusted_proxies private_ranges
        }
        rewrite /accounts/login* /oauth/login/?
    }
  '';
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
        DB_ROOT_PASSWD=${config.sops.placeholder."seafile/db-pass"}
        MYSQL_ROOT_PASSWORD=${config.sops.placeholder."seafile/db-pass"}
      '';
      "seafile-admin-env".content = ''
        SEAFILE_ADMIN_EMAIL=${config.sops.placeholder."seafile/email"}
        SEAFILE_ADMIN_PASSWORD=${config.sops.placeholder."seafile/password"}
      '';
    };
  };

  virtualisation.oci-containers.containers.seafile-server = {
    autoStart = true;
    dependsOn = [ "seafile-db" "memcached" "seafile-caddy" ];
    environment = {
      DB_HOST = "seafile-db";
      TIME_ZONE = "Asia/Shanghai";
      HTTPS = "true";
      SEAFILE_SERVER_HOSTNAME = "cloud-next.bukn.uk";
      GC_CRON = "0 6 * * 0";
    };
    environmentFiles = [ config.sops.templates."seafile-db-env".path ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/ggogel/seafile-server:${seafile-ver}";
    volumes = [ "${nas-path}/server-data:/shared" ];
  };

  virtualisation.oci-containers.containers.seahub = {
    autoStart = true;
    dependsOn = [ "seafile-server" "seahub-media" "seafile-caddy" ];
    environment = {
      SEAFILE_ADMIN_EMAIL = "me@example.com";
    };
    environmentFiles = [ config.sops.templates."seafile-admin-env".path ];
    extraOptions = [
      "--pod=seafile"
    ];
    image = "docker.io/ggogel/seahub:${seafile-ver}";
    volumes = [
      "${nas-path}/server-data:/shared"
    ];
  };

  virtualisation.oci-containers.containers.seahub-media = {
    autoStart = true;
    dependsOn = [ "seafile-caddy" ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/ggogel/seahub-media:${seafile-ver}";
    volumes = [
      "${seahub-media-caddyfile}:/etc/caddy/Caddyfile"
      "${nas-path}/server-data/seafile/seahub-data/avatars:/usr/share/caddy/media/avatars"
      "${nas-path}/server-data/seafile/seahub-data/custom:/usr/share/caddy/media/custom"
    ];
  };

  virtualisation.oci-containers.containers.seafile-db = {
    autoStart = true;
    environment = {
      MYSQL_LOG_CONSOLE = "true";
    };
    environmentFiles = [ config.sops.templates."seafile-db-env".path ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/mariadb:${mariadb-ver}";
    volumes = [
      "${nas-path}/db:/var/lib/mysql"
    ];
  };

  virtualisation.oci-containers.containers.memcached = {
    autoStart = true;
    cmd = [ "memcached" "-m 256" ];
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/memcached:${memcached-ver}";
  };

  virtualisation.oci-containers.containers.seafile-caddy = {
    autoStart = true;
    extraOptions = [ "--pod=seafile" ];
    image = "docker.io/ggogel/seafile-caddy:${caddy-ver}";
    volumes = [ "${seafile-caddy-caddyfile}:/etc/caddy/Caddyfile" ];
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
        "${backend}-seahub.service"
        "${backend}-seahub-media.service"
        "${backend}-seafile-db.service"
        "${backend}-memcached.service"
        "${backend}-seafile-caddy.service"
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
