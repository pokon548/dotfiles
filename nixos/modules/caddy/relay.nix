{ config, pkgs, ... }: {
  sops.secrets.caddy_config_relay = {
    sopsFile = ../../../secrets/relay.yaml;
    neededForUsers = true;
  };

  services.caddy-flavor = {
    enable = true;
    configFile = config.sops.secrets.caddy_config_relay.path;
  };
}
