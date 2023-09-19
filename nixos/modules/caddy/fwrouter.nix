{ config, ... }: {
  sops.secrets.caddy_config_fwrouter = {
    sopsFile = ../../../secrets/fwrouter.yaml;
    neededForUsers = true;
  };

  services.caddy = {
    enable = true;
    configFile = config.sops.secrets.caddy_config_fwrouter.path;
  };
}