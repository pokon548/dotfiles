{ lib, config, pkgs, ... }: {
  imports = [ ./dae.nix ./font.nix ./gnome-debloat.nix ];

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-chinese-addons fcitx5-gtk ];
  };

  # Workaround for fcitx5 issue under wayland. See: https://github.com/NixOS/nixpkgs/issues/129442
  environment.sessionVariables = {
    NIX_PROFILES =
      "${lib.concatStringsSep " " (lib.reverseList config.environment.profiles)}";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
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

  virtualisation = {
    libvirtd = {
      enable = true;
      allowedBridges = [
        "virbr0"
      ];
      qemu = {
        swtpm.enable = true;
        runAsRoot = true;
      };
    };
    virtualbox.host = {
      enable = true;
    };
  };
}
