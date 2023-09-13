{ inputs, ... }: {
  nixpkgs = {
    overlays = [ inputs.nur.overlay inputs.rust-overlay.overlays.default ];

    config = { allowUnfree = true; };
  };
}
