{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment = {
    gnome.excludePackages =
      (with pkgs; [
        baobab
        gnome-tour
        gnome-console
        gnome-connections
        tracker-miners
        tracker
      ])
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

  networking = { networkmanager.enable = true; };

  # TODO: Workaround for gdm crash issue, see https://github.com/NixOS/nixpkgs/issues/103746
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  networking.firewall =
    {
      allowedTCPPortRanges = [
        # KDE Connect
        { from = 1714; to = 1764; }
      ];
      allowedUDPPortRanges = [
        # KDE Connect
        { from = 1714; to = 1764; }
      ];
    };

  services.xserver.excludePackages = [ pkgs.xterm ];
}
