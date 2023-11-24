{ inputs, config, pkgs, lib, ... }:
let
  extensionPkgs = with pkgs.gnomeExtensions; [
    gsconnect
    appindicator
    dash-to-dock
    kimpanel

    clipboard-history
    emoji-copy
    just-perfection
    pip-on-top
    unmess
    always-indicator
    do-not-disturb-while-screen-sharing-or-recording
    native-window-placement
    weather-oclock
    night-theme-switcher

    blur-my-shell
    caffeine
    bing-wallpaper-changer
    hibernate-status-button
  ];
in
{
  sops.secrets.pokon548_password.neededForUsers = true;

  users.users.pokon548 = {
    hashedPasswordFile = config.sops.secrets.pokon548_password.path;
    shell = "${pkgs.fish}/bin/fish";
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
      ./modules/fish.nix
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
      nur.repos.pokon548.todoist-electron
      gnome-solanum
      goldendict-ng

      gnome-frog

      motrix
      obs-studio
      newsflash

      transmission_4-gtk
      nur.repos.pokon548.geogebra
      nur.repos.pokon548.zhixi

      ungoogled-chromium
      wpsoffice-cn
      libreoffice-fresh

      androidStudioPackages.canary
      godot_4

      (steam.override {
        extraPkgs = pkgs: [ openssl_1_1 ];
      })

      prismlauncher
      cartridges

      localsend

      celluloid
      bitwarden
      keepassxc
      element-desktop

      drawio
      anki-bin

      remmina

      tela-circle-icon-theme

      (kodi.passthru.withPackages (kodiPkgs: with kodiPackages; [
        inputstream-adaptive
        jellyfin
      ]))

      freetube

      nur.repos.pokon548.rustdesk-bin
      nur.repos.pokon548.chengla-electron
      nur.repos.pokon548.sticky
      nur.repos.federicoschonborn.metronome
      virt-manager

      gocryptfs
      nur.repos.pokon548.vaults

      nur.repos.pokon548.flowtime
      kooha

      android-tools
      scrcpy
      nmap

      abiword
      vlc
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
          "org.gnome.Console.desktop"
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
        sounds-volume = builtins.toJSON {
          rain = 0.57;
          storm = 0.29;
          wind = 1.0;
          waves = 0.38;
          stream = 0.54;
        };
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        workspaces-only-on-primary = false;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
      };

      "org/gnome/shell/app-switcher" = {
        current-workspace-only = true;
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        show-mounts = false;
        show-trash = false;
        show-show-apps-button = true;
      };

      "org/gnome/shell/extensions/just-perfection" = {
        app-menu = false;
      };

      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-1 = [ "<Alt>z" ];
        switch-to-workspace-2 = [ "<Alt>x" ];
        switch-to-workspace-3 = [ "<Alt>c" ];
        switch-to-workspace-4 = [ "<Alt>a" ];
        switch-to-workspace-5 = [ "<Alt>s" ];
        switch-to-workspace-6 = [ "<Alt>d" ];
        switch-to-workspace-7 = [ "<Alt>q" ];
        switch-to-workspace-8 = [ "<Alt>w" ];
        switch-to-workspace-9 = [ "<Alt>e" ];
        switch-to-workspace-10 = [ "<Alt>r" ];

        move-to-workspace-1 = [ "<Alt><Super>z" ];
        move-to-workspace-2 = [ "<Alt><Super>x" ];
        move-to-workspace-3 = [ "<Alt><Super>c" ];
        move-to-workspace-4 = [ "<Alt><Super>a" ];
        move-to-workspace-5 = [ "<Alt><Super>s" ];
        move-to-workspace-6 = [ "<Alt><Super>d" ];
        move-to-workspace-7 = [ "<Alt><Super>q" ];
        move-to-workspace-8 = [ "<Alt><Super>w" ];
        move-to-workspace-9 = [ "<Alt><Super>e" ];
        move-to-workspace-10 = [ "<Alt><Super>r" ];

        move-to-workspace-left = [ "<Alt><Super>Left" ];
        move-to-workspace-right = [ "<Alt><Super>Right" ];

        switch-to-workspace-left = [ "<Alt>Left" ];
        switch-to-workspace-right = [ "<Alt>Right" ];
      };

      "org/gnome/shell/extensions/pip-on-top" = {
        stick = true;
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "DND Quick Switch";
        binding = "<Super>z";
        command = "bash -c \"[[ $(gsettings get org.gnome.desktop.notifications show-banners) == 'false' ]] && gsettings set org.gnome.desktop.notifications show-banners true || gsettings set org.gnome.desktop.notifications show-banners false\"";
      };

      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = [ "<Super>s" ];
      };

      "org/gnome/shell/extensions/kimpanel" = {
        vertical = true;
      };

      "org/gnome/shell/weather" = {
        automatic-location = false;
      };

      "com/raggesilver/BlackBox" = {
        font = "FiraCode Nerd Font weight=450 11";
        window-width = lib.hm.gvariant.mkUint32 1366;
        window-height = lib.hm.gvariant.mkUint32 768;
        remember-window-size = true;
      };

      "org/gnome/Console" = {
        use-system-font = false;
        custom-font = "FiraCode Nerd Font 11";
      };

      "org/gnome/shell/extensions/clipboard-history" = {
        display-mode = 3;
      };

      "org/gnome/shell/extensions/caffeine" = {
        toggle-shortcut = [ "<Super>x" ];
        restore-state = true;
        inhibit-apps = [ "chengla-electron.desktop" "obsidian.desktop" "rustdesk-bin.desktop" "todoist.desktop" "org.remmina.Remmina.desktop" "codium.desktop" ];
      };

      "org/gnome/shell/extensions/unmess" = {
        classgroup = builtins.toJSON {
          SchildiChat = 1;
          Element = 1;
          Todoist = 1;
          thunderbird = 1;
          "org.gnome.Settings" = 1;
          "io.missioncenter.MissionCenter" = 1;
          gnome-tweaks = 1;
          "org.gnome.Extensions" = 1;

          Anki = 2;
          chengla-linux-unofficial = 2;
          "draw.io" = 2;
          Geogrebra = 2;
          GoldenDict-ng = 2;
          Obsidian = 2;

          "Android Studio" = 3;
          Vscodium = 3;
          Godot = 3;

          "org.prismlauncher.PrismLauncher" = 4;
          "hu.kramo.Cartridges" = 4;
          Steam = 4;
          steamwebhelper = 4;

          Rustdesk = 5;
          "org.remmina.Remmina" = 5;

          virt-manager = 6;
          Qemu-system-x86_64 = 6;
          "VirtualBox Manager" = 6;

          "io.gitlab.news_flash.NewsFlash" = 7;

          "io.bassi.Amberol" = 8;
          "com.rafaelmardojai.Blanket" = 8;
          FreeTube = 8;

          Bitwarden = 9;
          KeePassXC = 9;
          "fr.romainvigier.MetadataCleaner" = 9;
          "io.github.mpobaschnig.Vaults" = 9;

          ".scrcpy-wrapped" = 10;
        };

        classinstance = builtins.toJSON {
          schildichat = 1;
          element = 1;
          todoist = 1;
          thunderbird = 1;
          "org.gnome.Settings" = 1;
          "io.missioncenter.MissionCenter" = 1;
          gnome-tweaks = 1;
          "org.gnome.Extensions" = 1;

          anki = 2;
          chengla-linux-unofficial = 2;
          "draw.io" = 2;
          geogrebra = 2;
          goldenDict = 2;
          obsidian = 2;

          android-studio-canary = 3;
          vscodium = 3;
          Godot_ProjectList = 3;

          "org.prismlauncher.PrismLauncher" = 4;
          "hu.kramo.Cartridges" = 4;
          steam = 4;
          steamwebhelper = 4;

          rustdesk = 5;
          "org.remmina.Remmina" = 5;

          virt-manager = 6;
          qemu = 6;
          "VirtualBox Manager" = 6;

          "io.gitlab.news_flash.NewsFlash" = 7;

          "io.bassi.Amberol" = 8;
          "com.rafaelmardojai.Blanket" = 8;
          freetube = 8;

          bitwarden = 9;
          keepassxc = 9;
          "fr.romainvigier.MetadataCleaner" = 9;
          "io.github.mpobaschnig.Vaults" = 9;

          ".scrcpy-wrapped" = 10;
        };
      };
    };
  };
}
