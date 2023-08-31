{ config, pkgs, lib, ... }:
let
  extensionPkgs = with pkgs.gnomeExtensions; [
    gsconnect
    appindicator
    dash-to-dock
    runcat

    clipboard-history
    transparent-top-bar
    just-perfection

    caffeine

    night-theme-switcher
  ];
  inherit (lib.hm.gvariant) mkArray mkTuple mkString mkUint32 type;
in {
  sops.secrets.pokon548_password.neededForUsers = true;

  users.users.pokon548 = {
    passwordFile = config.sops.secrets.pokon548_password.path;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  home-manager.users.pokon548 = {
    imports = [ ./common.nix ./gnome.nix ./librewolf.nix ];

    home.packages = extensionPkgs ++ (with pkgs; [
      vim
      git

      amberol
      blackbox-terminal
      blanket
      eyedropper
      gnome.gnome-tweaks
      drawing
      metadata-cleaner
      obsidian
      thunderbird
      todoist-electron

      transmission_4-gtk

      ungoogled-chromium
      wpsoffice-cn
      libreoffice-fresh

      vscode-fhs

      vlc
      bitwarden
      keepassxc
      telegram-desktop

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
        favorite-apps = lib.mkBefore [
          "brave-browser.desktop"
          "com.raggesilver.BlackBox.desktop"
          "obsidian.desktop"
          "code.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };
    };
  };
}
