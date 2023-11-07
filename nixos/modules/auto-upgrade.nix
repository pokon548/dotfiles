{ ... }: {
  system.autoUpgrade = {
    enable = true;
    dates = "23:00";
    operation = "boot";

    allowReboot = true;
  };
}
