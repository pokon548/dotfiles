{ inputs, lib, ... }:
{

  imports = [
  ];

  perSystem =
    { inputs'
    , pkgs
    , ...
    }: {
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
                yarn
                wine
                wine64
                ungoogled-chromium
                cairo
                pango
                libjpeg
                libpng
                giflib
                librsvg
                pixman
                pkg-config
                glibc
                gcc_debug
                binutils
                stdenv.cc.cc.lib
                clang
                llvmPackages.bintools
                rustup
                rust-analyzer
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
            );
          }).env;

        learning = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            clang
            stdenv.cc.cc.lib
          ];

          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib64:$LD_LIBRARY_PATH";
        };

        openwrt = inputs.nix-environments.devShells."x86_64-linux".openwrt;
      };
    };
}
