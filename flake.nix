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

    # Authentik SSO
    authentik-nix.url = "github:nix-community/authentik-nix";

    # Filestash
    filestash-nix.url = "github:matthewcroughan/filestash-nix";
    
    # sops-nix
    sops-nix.url = "github:Mic92/sops-nix";

    nix-environments.url = "github:nix-community/nix-environments";

    # nix-index
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Lanzaboote
    lanzaboote.url = "github:nix-community/lanzaboote/v0.3.0";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    # Private configs
    private-configs.url = "git+ssh://gitea@gitea.bukn.uk:22222/pokon548/private-configs";
    private-configs.inputs.nixpkgs.follows = "nixpkgs";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm.url = "github:astro/microvm.nix/f92c94536c6be299730180a1a7caaab31e8657fb";

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
        systems = [ "x86_64-linux" "aarch64-linux" ];
        perSystem = { config, inputs', self', lib, system, ... }: {
          # make pkgs available to all `perSystem` functions
          _module.args.pkgs = inputs'.nixpkgs.legacyPackages;

          formatter = config.treefmt.build.wrapper;
        };
        # CI
      }).config.flake;
}
