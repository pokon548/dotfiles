{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/common.yaml;
    age.sshKeyPaths = [ "${config.users.${config.user}.home}/.ssh/id_ed25519" "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
