{ pkgs, ... }:
let
  commonExtensions = with pkgs.vscode-extensions; [
    vscodevim.vim
    vscode-icons-team.vscode-icons
    ms-ceintl.vscode-language-pack-zh-hans
    github.vscode-pull-request-github
    jnoortheen.nix-ide
    gruntfuggly.todo-tree
  ];
  frontendDevExtensions = with pkgs.vscode-extensions; [
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    bradlc.vscode-tailwindcss
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "vscode-postcss";
      publisher = "vunguyentuan";
      version = "2.0.2";
      sha256 = "ttvCwxk3dMwva5LmVHq4p31INTa/T91qQISEU4gYNbg=";
    }
  ];
in

{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    package = pkgs.vscodium;
    extensions = commonExtensions ++ frontendDevExtensions;
    mutableExtensionsDir = false;
    userSettings = {
      "window.dialogStyle" = "custom";
      "window.titleBarStyle" = "custom";
      "workbench.iconTheme" = "vscode-icons";
      "security.workspace.trust.enabled" = false;
      "editor.fontFamily" = "'JetBrains Mono', 'Droid Sans Mono', 'monospace', monospace";
      "window.zoomLevel" = 0.5;
    };
  };

  home.packages = with pkgs; [
    nixpkgs-fmt

    jetbrains-mono
  ];
}
