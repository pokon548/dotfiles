{ lib, config, pkgs, ... }: {
  imports = [ ./dae.nix ./font.nix ./gnome-debloat.nix ];

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-chinese-addons ];
  };

  networking.firewall.allowedTCPPortRanges = [
    # KDE Connect
    { from = 1714; to = 1764; }
  ];
  networking.firewall.allowedUDPPortRanges = [
    # KDE Connect
    { from = 1714; to = 1764; }
  ];

  services.xserver.excludePackages = [ pkgs.xterm ];

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "virbr0"
    ];
    qemu = {
      swtpm.enable = true;
      runAsRoot = true;
    };
  };

  virtualisation.virtualbox.host = {
    enable = true;
  };
}
