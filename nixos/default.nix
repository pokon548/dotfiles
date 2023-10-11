{ self, inputs, outputs, ... }:
let
  basicModules = {
    imports = [
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager

      ./modules/nix.nix
      ./modules/sops.nix
      ./modules/nixpkgs.nix
    ];
  };

  commonModules = {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.nur.nixosModules.nur
      inputs.nix-index-database.nixosModules.nix-index


      ./modules/dae.nix
      ./modules/i18n.nix
    ];
  };
  graphicModules = {
    imports = [
      ./modules/fcitx5.nix
      ./modules/pipewire.nix
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
        basicModules
        commonModules
        graphicModules

        ./hosts/surfacego
      ];
    };

    xiaoxin = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        basicModules
        commonModules
        graphicModules
        virtualisationModules

        inputs.microvm.nixosModules.host

        ./modules/lanzaboote.nix
        ./modules/workprofile.nix
        ./modules/zram.nix
        ./home/pokon548.nix
        ./hosts/xiaoxin
      ];
    };

    fwrouter = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        basicModules
        inputs.disko.nixosModules.disko

        ./home/bukun.nix
        ./modules/openssh.nix
        ./modules/caddy/fwrouter.nix
        ./hosts/fwrouter
      ];
    };

    hetzner = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        basicModules
        inputs.disko.nixosModules.disko

        ./home/bukun.nix
        ./modules/gitea.nix
        ./modules/openssh.nix
        ./modules/synapse.nix
        ./modules/caddy/hetzner.nix
        ./hosts/hetzner
      ];
    };
  };
}
