{ config, pkgs, lib, ... }:{
  users.users.worker = {
    password = "";
    group = "user";
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "worker";
  };

  # TODO: Introduce home-manager for vm
  environment.systemPackages = with pkgs; [
    obsidian
    bitwarden
    vivaldi
    vivaldi-ffmpeg-codecs
    keepassxc
    wpsoffice-cn
    ungoogled-chromium

    kwin
  ];
}
