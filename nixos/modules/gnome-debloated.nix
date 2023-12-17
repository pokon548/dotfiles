{ pkgs, lib, ... }: {
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  xdg.portal =
    { enable = true; xdgOpenUsePortal = true; };

  environment = {
    gnome.excludePackages =
      (with pkgs;
      [
        baobab
        gnome-tour
        tracker-miners
        tracker
      ])
      ++ (with pkgs.gnome; [
        cheese
        gnome-calendar
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

  environment.systemPackages = with pkgs; [
    adw-gtk3
    simp1e-cursors
  ];

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
