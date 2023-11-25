{ config, lib, pkgs, ... }:

let
  cfg = config.services.ntfy-server;
in
{
  options = {
    services.ntfy-server = with lib; {
      enable = mkEnableOption (mdDoc "Ntfy.sh server");

      baseUrl = mkOption {
        type = types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":33871";

        auth-default-access = "deny-all";

        base-url = "${cfg.baseUrl}";

        behind-proxy = true;
      };
    };
  };
}
