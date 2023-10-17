{ inputs, lib, ... }:
{

  imports = [
  ];

  perSystem =
    { inputs'
    , pkgs
    , ...
    }:
    let
      eachSystem = inputs.nixpkgs.lib.genAttrs [ "x86_64-linux" ];
      crossPkgs = eachSystem (system: import inputs.nixpkgs {
        inherit system;
        crossSystem.config = "riscv64-unknown-linux-gnu";
      });
    in
    {
      devShells = {
        default = pkgs.mkShell {
          # Enable experimental features without having to specify the argument
          NIX_CONFIG = "experimental-features = nix-command flakes";
          nativeBuildInputs = with pkgs; [ nix home-manager git ];
        };

        # For developing electron apps
        # Wine is included only for cross-compiling Windows binary. Feel free to remove them if you don't need :)
        electron = (pkgs.buildFHSUserEnv
          {
            name = "electron-env";
            targetPkgs = pkgs: (with pkgs;
              [
                nodejs
                python3
                libcxx
                systemd
                libpulseaudio
                libdrm
                mesa
                stdenv.cc.cc
                alsa-lib
                atk
                at-spi2-atk
                at-spi2-core
                cairo
                cups
                dbus
                expat
                fontconfig
                freetype
                gdk-pixbuf
                glib
                gtk3
                libnotify
                libuuid
                nspr
                nss
                pango
                systemd
                libappindicator-gtk3
                libdbusmenu
                libxkbcommon
                zlib
                nodePackages.pnpm
                cairo
                pango
                libjpeg
                libpng
                giflib
                librsvg
                pixman
                pkg-config
                gcc_debug
                glibc
                binutils
                stdenv.cc.cc.lib
                clang
                llvmPackages.bintools
                rustup
                rust-analyzer

                # For building window variant
                wine
                wine64

                # For building flatpak
                flatpak
                flatpak-builder
              ]
            ) ++ (with pkgs.xorg;
              [
                libXScrnSaver
                libXrender
                libXcursor
                libXdamage
                libXext
                libXfixes
                libXi
                libXrandr
                libX11
                libXcomposite
                libxshmfence
                libXtst
                libxcb
              ]
            ) ++ (with pkgs.pkgsCross; [ 
              mingwW64.buildPackages.gcc
              gnu64.buildPackages.gcc
            ]); # Cross-compiling windows binary on Linux. Feel free to remove them if you don't need :)
          }).env;

        learning = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            clang
            stdenv.cc.cc.lib
          ];

          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib64:$LD_LIBRARY_PATH";
        };

        gtk4-rust = pkgs.mkShell {
          buildInputs = with pkgs; [
            gtk4
            libadwaita
            cairo
            glib
            pkg-config
            librsvg

            cargo
            rustc
          ];

          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath (with pkgs; [
            pkg-config
            libadwaita
            glib
            gtk4
          ])}:$LD_LIBRARY_PATH";
        };

        openwrt = inputs.nix-environments.devShells."x86_64-linux".openwrt;
      };
    };
}
