{ ... }: {
  # TODO: Nixify
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };
}