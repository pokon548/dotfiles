{ ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;
      allowedBridges = [
        "virbr0"
      ];
      qemu = {
        swtpm.enable = true;
        runAsRoot = true;
      };
    };
  };
}
