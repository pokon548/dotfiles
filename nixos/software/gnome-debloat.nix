{ pkgs, ... }: {
  environment = {
    gnome.excludePackages =
      (with pkgs; [ baobab gnome-tour gnome-console gnome-connections ])
      ++ (with pkgs.gnome; [
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
