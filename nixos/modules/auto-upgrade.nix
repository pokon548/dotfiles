{ ... }: {
  system.autoUpgrade = {
    enable = true;
    dates = "Fri 04:00";
    operation = "boot";
  };
}
