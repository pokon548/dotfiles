{ config, pkgs, ... }: {
  sops.secrets.Caddyfile = {
    sopsFile = ../../../secrets/relay.yaml;
    owner = "caddy";
    group = "caddy";
  };

  services.caddy-flavor = {
    enable = true;
    configFile = config.sops.secrets.Caddyfile.path;
  };

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
  };
}
