{ config, pkgs, lib, ... }:
let
  inherit (lib.hm.gvariant)
    mkArray mkTuple mkString mkUint32 type;
in
{
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [ ];
      welcome-dialog-last-shown-version = "44.2";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/desktop/input-sources" = {
      sources = mkArray (type.tupleOf [ type.string type.string ]) [
        (mkTuple [ (mkString "xkb") (mkString "us") ])
        (mkTuple [ (mkString "ibus") (mkString "libpinyin") ])
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

    "org/gnome/system/location" = { enabled = true; };

    "org/gnome/shell/extensions/dash-to-dock" = {
      transparency-mode = "DYNAMIC";
      multi-monitor = true;
      isolate-monitors = true;
      show-mounts = false;
      custom-theme-shrink = true;
    };

    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      text-scaling-factor = 1.12;

      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      icon-theme = "Tela-circle-dark";

      show-battery-percentage = true;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      accessibility-menu = false;
      calendar = false;
      events-button = false;
      window-demands-attention-focus = true;
      startup-status = 0;
    };

    "desktop/ibus/general" = {
      preload-engines = [ "libpinyin" "xkb:us::eng" ];
    };
  };
}
