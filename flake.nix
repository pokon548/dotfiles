{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Rusty!
    rust-overlay.url = "github:oxalica/rust-overlay";

    # sops-nix
    sops-nix.url = "github:Mic92/sops-nix";

    # nix-index
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Lanzaboote
    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs @ { self, flake-parts, nixpkgs, ... }:
    (flake-parts.lib.evalFlakeModule
      { inherit inputs; }
      {
        imports = [
          ./nixos
          ./devshell
        ];
        systems = [ "x86_64-linux" ];
        perSystem = { config, inputs', self', lib, system, ... }: {
          # make pkgs available to all `perSystem` functions
          _module.args.pkgs = inputs'.nixpkgs.legacyPackages;

          formatter = config.treefmt.build.wrapper;
        };
        # CI
      }).config.flake;
}
