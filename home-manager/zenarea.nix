{ config, pkgs, lib, ... }:
let
  extensionPkgs = with pkgs.gnomeExtensions; [
    appindicator
    dash-to-dock

    clipboard-history
    transparent-top-bar
    just-perfection

    caffeine

    night-theme-switcher
  ];
  inherit (lib.hm.gvariant)
    mkArray mkTuple mkString mkUint32 type;
in {
  sops.secrets.zenarea_password.neededForUsers = true;

  users.users.zenarea = {
    passwordFile = config.sops.secrets.zenarea_password.path;
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };

  home-manager.users.zenarea = {
    imports = [
      ./gnome.nix
    ];

    home.packages = extensionPkgs ++ (with pkgs; [
      blanket
      obsidian

      nur.repos.pokon548.chengla-electron

      tela-circle-icon-theme
    ]);

    dconf.settings = {
      # Style
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri =
          "file:///run/current-system/sw/share/backgrounds/gnome/fold-l.webp";
        picture-uri-dark =
          "file:///run/current-system/sw/share/backgrounds/gnome/fold-d.webp";
        primary-color = "#26a269";
        secondary-color = "#000000";
      };

      "org/gnome/shell" = {
        enabled-extensions = map (p: p.extensionUuid) extensionPkgs;
      };
    };
  };
}
