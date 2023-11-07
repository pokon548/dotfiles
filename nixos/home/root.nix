{ inputs, config, pkgs, lib, ... }:
{
  users.users.root = {
    hashedPassword = "!";
    shell = "${pkgs.bash}/bin/bash";
    extraGroups = [ "networkmanager" ];
  };

  home-manager.users.root = {
    imports = [ ./modules/common.nix ];

    home.packages = with pkgs; [
      vim
      git
    ];
  };
}
