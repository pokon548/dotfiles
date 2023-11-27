{ inputs, config, pkgs, lib, ... }:
{
  # For security, each remote machine is set with different password
  sops.secrets."bukun_password_${config.networking.hostName}" = {
    sopsFile = ../../secrets/${config.networking.hostName}.yaml;
    neededForUsers = true;
  };

  users.users.bukun = {
    hashedPasswordFile = config.sops.secrets."bukun_password_${config.networking.hostName}".path;
    shell = "${pkgs.fish}/bin/fish";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  home-manager.users.bukun = {
    imports = [ inputs.nix-index-database.hmModules.nix-index ./modules/common.nix ];

    home.packages = with pkgs; [
      vim
      git
    ];
  };
}
