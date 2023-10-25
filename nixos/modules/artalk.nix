{ config, lib, pkgs, ... }:

let
  cfg = config.networking.artalk-server;
in
{
  options = {
    networking.artalk-server = with lib; {
      enable = mkEnableOption (mdDoc "Artalk server");
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        artalk = {
          autoStart = true;
          image = "docker.io/artalk/artalk-go:latest";
          ports = [
            "23366:23366"
          ];
          volumes = [
            "/mnt/external-storage/artalk:/data"
          ];
          environmentFiles = [ ];
        };
      };
    };
  };
}
