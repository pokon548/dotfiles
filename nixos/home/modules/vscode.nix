{ pkgs, ... }:
let
  commonExtensions = with pkgs.vscode-extensions; [
    vscodevim.vim
    vscode-icons-team.vscode-icons
    ms-ceintl.vscode-language-pack-zh-hans
    github.vscode-pull-request-github
    jnoortheen.nix-ide
    arrterian.nix-env-selector
    gruntfuggly.todo-tree
    rust-lang.rust-analyzer
  ];
  shellScriptExtensions = with pkgs.vscode-extensions; [
    foxundermoon.shell-format
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
    {
      name = "playwright";
      publisher = "ms-playwright";
      version = "1.0.15";
      sha256 = "3G/xMKzsXLP7aJm9tBLDZQD0rRF28sHzo0Y2TiDP3ME=";
    }
  ];
in

{
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    package = pkgs.vscodium;
    extensions = commonExtensions ++ shellScriptExtensions ++ frontendDevExtensions;
    mutableExtensionsDir = false;
    userSettings = {
      "window.dialogStyle" = "custom";
      "window.titleBarStyle" = "custom";
      "workbench.iconTheme" = "vscode-icons";
      "security.workspace.trust.enabled" = false;
      "editor.fontFamily" = "'JetBrains Mono', 'Droid Sans Mono', 'monospace', monospace";
      "window.zoomLevel" = 0.5;
      "todo-tree.general.tags" = [
        "BUG"
        "HACK"
        "FIXME"
        "TODO"
        "XXX"
      ];
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[jsonc]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[json]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[html]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "window.commandCenter" = false;
    };
  };

  home.packages = with pkgs; [
    nixpkgs-fmt

    jetbrains-mono
  ];
}
