{ config, lib, pkgs, ... }:

let
  cfg = config.networking.samba;
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
      secrets = {
        gitea-cifs-username = { };
        gitea-cifs-password = { };
        gitea-cifs-domain = { };

        seafile-cifs-username = { };
        seafile-cifs-password = { };
        seafile-cifs-domain = { };

        microbin-cifs-username = { };
        microbin-cifs-password = { };
        microbin-cifs-domain = { };

        wikijs-cifs-username = { };
        wikijs-cifs-password = { };
        wikijs-cifs-domain = { };
      };
    };

    sops.templates."gitea-smb-secrets".content = ''
      username=${config.sops.placeholder."gitea-cifs-username"}
      domain=${config.sops.placeholder."gitea-cifs-domain"}
      password=${config.sops.placeholder."gitea-cifs-password"}
    '';

    sops.templates."seafile-smb-secrets".content = ''
      username=${config.sops.placeholder."seafile-cifs-username"}
      domain=${config.sops.placeholder."seafile-cifs-domain"}
      password=${config.sops.placeholder."seafile-cifs-password"}
    '';

    sops.templates."microbin-smb-secrets".content = ''
      username=${config.sops.placeholder."microbin-cifs-username"}
      domain=${config.sops.placeholder."microbin-cifs-domain"}
      password=${config.sops.placeholder."microbin-cifs-password"}
    '';

    sops.templates."wikijs-smb-secrets".content = ''
      username=${config.sops.placeholder."wikijs-cifs-username"}
      domain=${config.sops.placeholder."wikijs-cifs-domain"}
      password=${config.sops.placeholder."wikijs-cifs-password"}
    '';

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
          automount_opts = "_netdev,x-systemd.automount,hard,nofail,x-systemd.device-timeout=10ms,mfsymlinks,uid=995,gid=995";

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
  };
}
