{ config, pkgs, lib, ... }:

with lib;

{
  options = {
    services.dae = {
      enable = options.mkEnableOption (mdDoc "the dae service");
    };
  };

  config = mkIf config.services.dae.enable {
    environment.systemPackages = [ pkgs.dae ];

    networking.firewall.allowedTCPPorts = [ 12345 ];
    networking.firewall.allowedUDPPorts = [ 12345 ];

    systemd.services.dae =
      {
        unitConfig = {
          Description = "dae Service";
          Documentation = "https://github.com/daeuniverse/dae";
          After = [
            "network.target"
            "systemd-sysctl.service"
          ];
          Wants = [ "network.target" ];
        };

        serviceConfig = {
          User = "root";
          ExecStartPre = "${getExe pkgs.dae} validate -c /etc/dae/config.dae";
          ExecStart = "${getExe pkgs.dae} run --disable-timestamp -c /etc/dae/config.dae";
          ExecReload = "${getExe pkgs.dae} reload $MAINPID";
          LimitNPROC = 512;
          LimitNOFILE = 1048576;
          Restart = "on-abnormal";
          Type = "notify";
        };

        wantedBy = [ "multi-user.target" ];
      };
  };
}
