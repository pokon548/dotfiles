{ inputs, config, pkgs, lib, ... }:
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

    blur-my-shell

    caffeine

    bing-wallpaper-changer

    night-theme-switcher
  ];
  inherit (lib.hm.gvariant) mkArray mkTuple mkString mkUint32 type;
in
{
  sops.secrets.pokon548_password.neededForUsers = true;

  users.users.pokon548 = {
    hashedPasswordFile = config.sops.secrets.pokon548_password.path;
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "kvm" "libvirt" "vboxusers" ];
  };

  home-manager.users.pokon548 = {
    imports = [ inputs.nix-index-database.hmModules.nix-index ./modules/common.nix ./modules/gnome.nix ./modules/librewolf.nix ./modules/vscode.nix ./modules/ohmyzsh.nix ];

    # TODO: Remove openssl_1 if mono no longer depend on it
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
      gnome-solanum
      goldendict-ng

      motrix

      obs-studio

      transmission_4-gtk

      ungoogled-chromium
      wpsoffice-cn
      libreoffice-fresh

      androidStudioPackages.canary
      godot_4

      (steam.override {
        extraPkgs = pkgs: [ openssl_1_1 ];
      })

      prismlauncher

      localsend

      vlc
      bitwarden
      keepassxc
      telegram-desktop
      element-desktop

      anki-bin

      tela-circle-icon-theme

      nur.repos.pokon548.rustdesk-bin
      nur.repos.pokon548.chengla-electron
      virt-manager
    ]);

    dconf.settings = {
      # Style
      "org/gnome/desktop/background" = {
        primary-color = "#26a269";
        secondary-color = "#000000";
      };

      "org/gnome/shell" = {
        enabled-extensions = map (p: p.extensionUuid) extensionPkgs;
        favorite-apps = lib.mkBefore [
          "librewolf.desktop"
          "com.raggesilver.BlackBox.desktop"
          "obsidian.desktop"
          "codium.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      "org/gnome/nautilus/icon-view" = {
        default-zoom-level = "small";
      };

      "org/gnome/nautilus/preferences" = {
        click-policy = "single";
      };

      "org/gnome/Solanum" = {
        lap-length = "unit32 45";
        sessions-until-long-break = "unit32 3";
      };
    };
  };
}
