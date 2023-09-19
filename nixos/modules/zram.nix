{ ... }:
{
  zramSwap = {
    enable = true;
  };

  services.zram-generator = {
    enable = true;
  };
}
