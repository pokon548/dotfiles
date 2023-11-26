{ config, lib, pkgs, ... }:

let
  nas-path = "/mnt/external-storage/send";
in
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      send = {
        autoStart = true;
        image = "ghcr.io/xavion-lux/send:latest";
        environment = {
          DETECT_BASE_URL = "true";
          REDIS_HOST = "localhost";
          FILE_DIR = "/uploads";
        };
        ports = [ "1443:1443" ];
        volumes = [ "${nas-path}/uploads:/uploads" ];
        user = "nobody:nogroup";
        extraOptions = [ "--network=host" ];
      };
    };
  };
}
