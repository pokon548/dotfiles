{ ... }: {
  system.autoUpgrade = {
    enable = true;
    dates = "23:00";
    operation = "switch";

    flags = [
      "--update-input"
      "nixpkgs"
    ];
    allowReboot = true;
  };
}
