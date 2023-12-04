{ config, lib, pkgs, ... }:

# TODO: We should elimate mountFolder, as it is only created for maintain backward compability.
# NEVER make mountFolder different from name in future service!

let
  cfg = config.networking.samba;
  basePath = "/mnt/external-storage";
  baseSMBPath = "u370687-sub";
  services = [
    { name = "gitea"; uid = 995; mountFolder = "gitea"; subAccountId = 2; }
    { name = "seafile"; uid = 0; mountFolder = "seafile"; subAccountId = 3; } # TODO: Not safe to use root account
    { name = "microbin"; uid = 65534; mountFolder = "pastebin"; subAccountId = 5; }
    { name = "wikijs"; uid = 65534; mountFolder = "wiki-js"; subAccountId = 1; }
    { name = "send"; uid = 65534; mountFolder = "send"; subAccountId = 8; }
  ];
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
              { name = x.name + "-cifs-username"; value = { }; }
              { name = x.name + "-cifs-password"; value = { }; }
              { name = x.name + "-cifs-domain"; value = { }; }
            ])
            services));

      templates = builtins.listToAttrs (
        builtins.concatLists (
          map
            (x: [
              {
                name = x.name + "-smb-secrets";
                value = {
                  content = ''
                    username=${config.sops.placeholder."${x.name}-cifs-username"}
                    domain=${config.sops.placeholder."${x.name}-cifs-domain"}
                    password=${config.sops.placeholder."${x.name}-cifs-password"}
                  '';
                };
              }
            ])
            services));
    };

    fileSystems = builtins.listToAttrs
      (
        builtins.concatLists (
          map
            (x: [
              {
                name = basePath + "/" + x.mountFolder;
                value = {
                  device = "//" + baseSMBPath + builtins.toString (x.subAccountId) + ".your-storagebox.de/" + baseSMBPath + builtins.toString (x.subAccountId);
                  fsType = "cifs";
                  options =
                    let
                      # this line prevents hanging on network split
                      automount_opts = "_netdev,x-systemd.automount,nofail,x-systemd.device-timeout=10ms,mfsymlinks,uid=${builtins.toString (x.uid)},gid=${builtins.toString (x.uid)}";

                    in
                    [ "${automount_opts},credentials=${config.sops.templates."${x.name}-smb-secrets".path}" ];
                };
              }
            ])
            services));
  };
}
