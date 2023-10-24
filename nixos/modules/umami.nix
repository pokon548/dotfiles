{ config, lib, pkgs, ... }:

let
  cfg = config.networking.umami-server;
in
{
  options = {
    networking.umami-server = with lib; {
      enable = mkEnableOption (mdDoc "Umami server");

      environmentFile = mkOption {
        type = types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        umami = {
          autoStart = true;
          image = "ghcr.io/umami-software/umami:postgresql-latest";
          environment = {
            "DATABASE_URL" = "postgres://umami:umami@localhost:${toString config.services.postgresql.port}/umami";
          };
          environmentFiles = [ ];
          extraOptions = [ "--network=host" ];
        };
      };
    };
  };
}
