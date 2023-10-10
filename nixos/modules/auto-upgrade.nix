{ ... }: {
  system.autoUpgrade = {
    enable = true;
    dates = "Fri 04:00";
    operation = "switch";

    allowReboot = true;
    rebootWindow = {
      lower = "01:00";
      upper = "03:00";
    };
  };
}
