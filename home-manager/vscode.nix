{ ... }:

{
    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        ms-ceintl.vscode-language-pack-zh-hans
      ];
      userSettings = {
        "window.dialogStyle" = "custom";
        "window.titleBarStyle" = "custom";
      };
    };
}