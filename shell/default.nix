# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through 'nix develop' or (legacy) 'nix-shell'

{ pkgs }: {
  default = pkgs.mkShell {
    # Enable experimental features without having to specify the argument
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs; [ nix home-manager git ];
  };

  # For developing electron apps
  # Wine is included only for cross-compiling Windows binary. Feel free to remove them if you don't need :)
  electron = pkgs.mkShell {
    nativeBuildInputs = pkgs:
      (with pkgs; [ nodejs electron wine wine64 stdenv.cc.cc.lib ]);

    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib64:$LD_LIBRARY_PATH";
    ELECTRON_OVERRIDE_DIST_PATH = "${pkgs.electron}/bin/";
  };
}
