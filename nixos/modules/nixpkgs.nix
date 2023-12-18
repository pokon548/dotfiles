{ inputs, pkgs, ... }: {
  nixpkgs = {
    overlays = [
      inputs.nur.overlay
      inputs.rust-overlay.overlays.default
      inputs.microvm.overlay

      (self: super: {
        gnome = super.gnome.overrideScope' (gself: gsuper: {
          mutter = gsuper.mutter.overrideAttrs (old: {
            patches = [ ./gnome-patch/mr1441.patch ./gnome-patch/mr3327.patch ];
          });

          gnome-shell = gsuper.gnome-shell.overrideAttrs (old: {
            patches = old.patches ++ [ ./gnome-patch/no-screenshot-flash.patch ./gnome-patch/no-workspace-animation.patch ];
          });
        });
      })
    ];

    config =
      {
        allowUnfree = true;
        permittedInsecurePackages = [
          "openssl-1.1.1w"
          "electron-25.9.0"
        ];
      };
  };
}
