{ pkgs, ... }: let commonExtensions = with pkgs.vscode-extensions; [
  vscodevim.vim
  vscode-icons-team.vscode-icons
  ms-ceintl.vscode-language-pack-zh-hans
];
in 

{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    package = pkgs.vscodium;
    extensions = commonExtensions;
    userSettings = {
      "window.dialogStyle" = "custom";
      "window.titleBarStyle" = "custom";
      "workbench.iconTheme" = "vscode-icons";
    };
  };
}