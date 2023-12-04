{ config, lib, pkgs, ... }:

# TODO: Pasta code found. Any elegant ideas?
let
  cfg = config.networking.samba;
  services = [ "gitea" "seafile" "microbin" "wikijs" "send" ];
in
{
  options = {
    networking.samba = with lib; {
      hetzner = mkEnableOption (mdDoc "Enable hetzner smaba mounts");
    };
  };

  config = lib.mkIf cfg.hetzner {
    environment.systemPackages = [ pkgs.cifs-utils ];

    sops = {
      defaultSopsFile = lib.mkForce ../../secrets/hetzner.yaml;

      secrets = builtins.listToAttrs (
        builtins.concatLists (
          map
            (x: [
              { name = x + "-cifs-username"; value = { }; }
              { name = x + "-cifs-password"; value = { }; }
              { name = x + "-cifs-domain"; value = { }; }
            ])
            services));

      templates = builtins.listToAttrs (
        builtins.concatLists (
          map
            (x: [
              {
                name = x + "-smb-secrets";
                value = {
                  content = ''
                    username=${config.sops.placeholder."${x}-cifs-username"}
                    domain=${config.sops.placeholder."${x}-cifs-domain"}
                    password=${config.sops.placeholder."${x}-cifs-password"}
                  '';
                };
              }
            ])
            services));
    };

    fileSystems."/mnt/external-storage/wiki-js" = {
      device = "//u370687-sub1.your-storagebox.de/u370687-sub1";
      fsType = "cifs";
      options =
        let
          # this line prevents hanging on network split
          automount_opts = "_netdev,x-systemd.automount,nofail,x-systemd.device-timeout=10ms,mfsymlinks,uid=65534,gid=65534";

        in
        [ "${automount_opts},credentials=${config.sops.templates."wikijs-smb-secrets".path}" ];
    };

    fileSystems."/mnt/external-storage/gitea" = {
      device = "//u370687-sub2.your-storagebox.de/u370687-sub2";
      fsType = "cifs";
      options =
        let
          # this line prevents hanging on network split
          automount_opts = "_netdev,x-systemd.automount,nofail,x-systemd.device-timeout=10ms,mfsymlinks,uid=995,gid=995";

        in
        [ "${automount_opts},credentials=${config.sops.templates."gitea-smb-secrets".path}" ];
    };

    fileSystems."/mnt/external-storage/seafile" = {
      device = "//u370687-sub3.your-storagebox.de/u370687-sub3";
      fsType = "cifs";
      options =
        let
          # this line prevents hanging on network split
          automount_opts = "_netdev,x-systemd.automount,hard,nofail,x-systemd.device-timeout=10ms,mfsymlinks,uid=0,gid=0";

        in
        [ "${automount_opts},credentials=${config.sops.templates."seafile-smb-secrets".path}" ];
    };

    fileSystems."/mnt/external-storage/pastebin" = {
      device = "//u370687-sub5.your-storagebox.de/u370687-sub5";
      fsType = "cifs";
      options =
        let
          # this line prevents hanging on network split
          automount_opts = "_netdev,x-systemd.automount,nofail,x-systemd.device-timeout=10ms,mfsymlinks,uid=65534,gid=65534";

        in
        [ "${automount_opts},credentials=${config.sops.templates."microbin-smb-secrets".path}" ];
    };

    fileSystems."/mnt/external-storage/send" = {
      device = "//u370687-sub6.your-storagebox.de/u370687-sub8";
      fsType = "cifs";
      options =
        let
          # this line prevents hanging on network split
          automount_opts = "_netdev,x-systemd.automount,nofail,x-systemd.device-timeout=10ms,mfsymlinks,uid=65534,gid=65534";

        in
        [ "${automount_opts},credentials=${config.sops.templates."send-smb-secrets".path}" ];
    };
  };
}
