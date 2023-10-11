{ ... }: {
  system.autoUpgrade = {
    enable = true;
    dates = "Fri 23:00";
    operation = "boot";

    allowReboot = true;
    rebootWindow = {
      lower = "01:00";
      upper = "03:00";
    };
  };
}
