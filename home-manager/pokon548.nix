{ config, pkgs, lib, ... }:
let
  extensionPkgs = with pkgs.gnomeExtensions; [
    gsconnect
    appindicator
    dash-to-dock
    runcat

    kimpanel

    clipboard-history
    transparent-top-bar
    just-perfection

    caffeine

    bing-wallpaper-changer

    night-theme-switcher
  ];
  inherit (lib.hm.gvariant) mkArray mkTuple mkString mkUint32 type;
in {
  sops.secrets.pokon548_password.neededForUsers = true;

  users.users.pokon548 = {
    passwordFile = config.sops.secrets.pokon548_password.path;
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "kvm" "libvirt" "vboxusers" ];
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
      gnome.gnome-system-monitor
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
      androidStudioPackages.canary

      steam
      prismlauncher

      vlc
      bitwarden
      keepassxc
      telegram-desktop

      tela-circle-icon-theme

      nur.repos.pokon548.nekoray-bin
      virt-manager
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
          "librewolf.desktop"
          "com.raggesilver.BlackBox.desktop"
          "obsidian.desktop"
          "code.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      "org/gnome/nautilus/icon-view" = {
        default-zoom-level = "small";
      };

      "org/gnome/nautilus/preferences" = {
        click-policy = "single";
      };
    };
  };
}
