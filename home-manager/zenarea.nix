{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  extensionPkgs = with pkgs.gnomeExtensions; [
      appindicator
      dash-to-dock

      clipboard-history
      transparent-top-bar
      just-perfection

      caffeine

      night-theme-switcher
    ];
  inherit (inputs.home-manager.lib.hm.gvariant) mkArray mkTuple mkString mkUint32 type;
in
{
  sops.secrets.zenarea_password.neededForUsers = true;

  users.users.zenarea = {
    passwordFile = config.sops.secrets.zenarea_password.path;
    isNormalUser = true;
    extraGroups = [ "networkmanager"];
  };

  home-manager.users.zenarea = {
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
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/fold-l.webp";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/fold-d.webp";
        primary-color = "#26a269";
        secondary-color = "#000000";
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = map (p: p.extensionUuid) extensionPkgs;
        disabled-extensions = [];
        favorite-apps = lib.mkBefore [
          "brave-browser.desktop"
          "com.raggesilver.BlackBox.desktop"
          "obsidian.desktop"
          "code.desktop"
          "org.gnome.Nautilus.desktop"
        ];
        welcome-dialog-last-shown-version = "44.2";
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      "org/gnome/desktop/input-sources" = {
        sources = mkArray (type.tupleOf [type.string type.string]) [
          (mkTuple [(mkString "xkb") (mkString "us")])
          (mkTuple [(mkString "ibus") (mkString "libpinyin")])
        ];
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
      };

      "org/gnome/shell/extensions/nightthemeswitcher/time" = {
        manual-schedule = false;
      };

      "org/gnome/shell/extensions/nightthemeswitcher/gtk-variants" = {
        enabled = true;
      };

      "org/gnome/shell/extensions/nightthemeswitcher/icon-variants" = {
        enabled = true;
        day = "Tela-circle-light";
        night = "Tela-circle-dark";
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
        edge-scrolling-enabled = false;
      };

      "org/gnome/system/location" = {
        enabled = true;
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        transparency-mode = "DYNAMIC";
      };

      "org/gnome/desktop/interface" = {
        clock-show-weekday = true;
        text-scaling-factor = 1.12;
      };

      "desktop/ibus/general" = {
        preload-engines = [ "libpinyin" "xkb:us::eng" ];
      };
    };
  };
}
