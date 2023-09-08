{ pkgs, ... }:
let
  commonExtensions = with pkgs.vscode-extensions; [
    vscodevim.vim
    vscode-icons-team.vscode-icons
    ms-ceintl.vscode-language-pack-zh-hans
    jnoortheen.nix-ide
  ];
in

{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    package = pkgs.vscodium;
    extensions = commonExtensions;
    mutableExtensionsDir = false;
    userSettings = {
      "window.dialogStyle" = "custom";
      "window.titleBarStyle" = "custom";
      "workbench.iconTheme" = "vscode-icons";
    };
  };

  home.packages = with pkgs; [
    nixpkgs-fmt
  ];
}
