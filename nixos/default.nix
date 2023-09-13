{ self, inputs, outputs, ... }:
let
  commonModules = {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.nur.nixosModules.nur
      inputs.nix-index-database.nixosModules.nix-index
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager

      ./modules/auto-upgrade.nix
      ./modules/dae.nix
      ./modules/nix.nix
      ./modules/nixpkgs.nix
      ./modules/i18n.nix
      ./modules/sops.nix
    ];
  };
  graphicModules = {
    imports = [
      ./modules/fcitx5.nix
      ./modules/font.nix
      ./modules/gnome-debloated.nix
    ];
  };
  virtualisationModules = {
    imports = [
      ./modules/virtualbox.nix
      ./modules/libvirt.nix
    ];
  };
in
{
  flake.nixosConfigurations = {
    surfacego = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        commonModules
        graphicModules

        ./surfacego
      ];
    };

    xiaoxin = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        commonModules
        graphicModules
        virtualisationModules

        ./modules/lanzaboote.nix
        ./xiaoxin
      ];
    };
  };
}
