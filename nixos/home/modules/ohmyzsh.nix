{ pkgs, config, ... }: {
  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      ma = "for i in $(adb devices); do scrcpy -s $i -w -S &; done";
      update = "sudo nixos-rebuild switch";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    initExtra = "source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh";
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "vi-mode" "sudo" ];
      theme = "robbyrussell";
    };
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
}
