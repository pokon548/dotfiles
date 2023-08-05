{ lib, config, pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
  };

  services.v2raya.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  environment = {
    systemPackages = with pkgs; [
    ];

    gnome.excludePackages = (with pkgs; [
      baobab
      gnome-tour
      gnome-console
      gnome-connections
    ]) ++ (with pkgs.gnome; [
      cheese
      gnome-terminal
      gnome-calendar
      gnome-weather
      gnome-music
      gnome-contacts
      gnome-maps
      gnome-disk-utility
      gnome-logs
      gnome-system-monitor
      gnome-font-viewer
      epiphany
      simple-scan
      geary
      yelp
      seahorse
      gnome-characters
      totem
    ]);
  };
}
