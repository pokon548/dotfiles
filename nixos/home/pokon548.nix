{ inputs, config, pkgs, lib, ... }:
let
  extensionPkgs = with pkgs.gnomeExtensions; [
    gsconnect
    appindicator
    dash-to-dock
    runcat

    kimpanel

    clipboard-history
    emoji-copy
    transparent-top-bar
    just-perfection
    pip-on-top
    cronomix

    blur-my-shell
    caffeine
    bing-wallpaper-changer
    night-theme-switcher
    hibernate-status-button
  ];
in
{
  sops.secrets.pokon548_password.neededForUsers = true;

  users.users.pokon548 = {
    hashedPasswordFile = config.sops.secrets.pokon548_password.path;
    shell = "${pkgs.zsh}/bin/zsh";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "kvm" "qemu" "libvirt" "vboxusers" "tss" "pipewire" ];
  };

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "pokon548";
  };

  home-manager.users.pokon548 = { lib, ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index

      ./modules/common.nix
      ./modules/gnome.nix
      ./modules/librewolf.nix
      ./modules/vscode.nix
      ./modules/syncthing.nix
      ./modules/ohmyzsh.nix
    ];

    # TODO: Remove openssl_1 if mono no longer depend on it
    home.packages = extensionPkgs ++ (with pkgs; [
      vim
      git

      amberol
      blackbox-terminal
      blanket
      eyedropper
      gnome.gnome-tweaks
      mission-center
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
      geogebra6

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
      element-desktop

      drawio
      anki-bin

      tela-circle-icon-theme

      nur.repos.pokon548.rustdesk-bin
      nur.repos.pokon548.chengla-electron
      nur.repos.federicoschonborn.metronome
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
        lap-length = lib.hm.gvariant.mkUint32 45;
        sessions-until-long-break = lib.hm.gvariant.mkUint32 3;
      };

      "org/gnome/shell/extensions/emoji-copy" = {
        always-show = false;
      };

      "org/gnome/shell/extensions/bingwallpaper" = {
        hide = true;
      };

      "com/adrienplazas/Metronome" = {
        beats-per-minute = lib.hm.gvariant.mkUint32 20;
        beats-per-bar = lib.hm.gvariant.mkUint32 4;
      };

      "com/rafaelmardojai/Blanket" = {
        active-preset = "e3a69a28-e8bc-402d-8c29-388f19d8b301";
        background-playback = true;
      };

      "com/rafaelmardojai/Blanket/e3a69a28-e8bc-402d-8c29-388f19d8b301" = {
        visible-name = "Peace";
        sounds-volume = ''{"rain": 0.57,"storm": 0.29,"wind": 1.0,"waves" = 0.38,"stream" = 0.54}'';
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        workspaces-only-on-primary = false;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 6;
      };

      "org/gnome/shell/app-switcher" = {
        current-workspace-only = true;
      };
    };
  };
}
