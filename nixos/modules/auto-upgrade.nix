{ ... }: {
  system.autoUpgrade = {
    enable = true;
    dates = "23:00";
    operation = "boot";

    flags = [
      "--update-input"
      "nixpkgs"
    ];
    allowReboot = true;
  };
}
