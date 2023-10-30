{ pkgs, config, ... }: {
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      ma = "for i in $(adb devices); do scrcpy -s $i -w -S &; done";
      update = "sudo nixos-rebuild switch";
    };
    interactiveShellInit = "source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh";
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };
}
