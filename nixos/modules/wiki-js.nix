{ config, lib, pkgs, ... }:

let
  cfg = config.networking.wiki-js-server;

  package-settings = {
    db = {
      host = "localhost";
      user = "wikijs";
      type = "postgres";
      pass = "wikijs";
    };
    port = 46178;
  };

  format = pkgs.formats.json { };

  configFile = format.generate "wiki-js.yml" package-settings;
in
{
  options = {
    networking.wiki-js-server = with lib; {
      enable = mkEnableOption (mdDoc "Wiki-js server");

      stateDir = mkOption {
        type = types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.wiki-js = {
      enable = true;
      settings = package-settings;
    };
    systemd.services.wiki-js = {
      preStart = lib.mkForce ''
        ln -sf ${configFile} ${cfg.stateDir}/config.yml
        ln -sf ${pkgs.wiki-js}/server ${cfg.stateDir}
        ln -sf ${pkgs.wiki-js}/assets ${cfg.stateDir}
        ln -sf ${pkgs.wiki-js}/package.json ${cfg.stateDir}/package.json
      '';

      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "nobody";
        group = "nogroup";
        WorkingDirectory = lib.mkForce "${cfg.stateDir}";
      };
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        wikijs-sitemap = {
          autoStart = true;
          image = "docker.io/hostwiki/wikijs-sitemap:latest";
          environment = {
            DB_TYPE = "postgres";
            DB_HOST = "localhost";
            DB_PORT = "5432";
            DB_PASS = "wikijs";
            DB_USER = "wikijs";
            DB_NAME = "wiki";
          };
          environmentFiles = [ ];
          extraOptions = [ "--network=host" ];
        };
      };
    };
  };
}
