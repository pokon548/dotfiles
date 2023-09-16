{ ... }: {
  sops.secrets.caddy_config_fwrouter.neededForUsers = true;

  services.caddy = {
    enable = true;
    configFile = config.sops.secrets.caddy_config_fwrouter.path;
  };
}