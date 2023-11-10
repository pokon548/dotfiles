{ ... }: {
  system.autoUpgrade = {
    enable = true;
    dates = "monthly";
    operation = "boot";

    allowReboot = false;
  };
}
