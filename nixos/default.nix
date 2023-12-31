{ self, inputs, outputs, ... }:
let
  basicModules = {
    imports = [
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager

      ./modules/nix.nix
      ./modules/sops.nix
      ./modules/sudo.nix
      ./modules/nixpkgs.nix
    ];
  };

  commonModules = {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.nur.nixosModules.nur
      inputs.nix-index-database.nixosModules.nix-index

      # ./modules/dae.nix
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
        inputs.private-configs.nixosModules

        ./modules/lanzaboote.nix
        ./modules/ananicy.nix
        ./modules/dae.nix
        ./modules/zram.nix
        ./home/pokon548.nix
        ./hosts/xiaoxin
      ];
    };

    relay = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        basicModules
        inputs.private-configs.nixosModules
        inputs.disko.nixosModules.disko

        ./home/bukun.nix
        ./modules/auto-upgrade.nix
        ./modules/openssh.nix
        ./modules/ssh-totp-auth.nix
        ./modules/zram.nix
        ./modules/caddy/relay.nix
        ./hosts/relay
      ];
    };

    hetzner = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        basicModules
        inputs.disko.nixosModules.disko
        inputs.private-configs.nixosModules
        inputs.authentik-nix.nixosModules.default
        inputs.filestash-nix.nixosModule

        ./home/bukun.nix
        ./home/root.nix
        ./modules/auto-upgrade.nix
        ./modules/gitea.nix
        ./modules/microbin.nix
        ./modules/samba.nix
        #./modules/filestash.nix
        ./modules/seafile.nix
        ./modules/ssh-totp-auth.nix
        ./modules/openssh.nix
        ./modules/send.nix
        ./modules/shlink.nix
        ./modules/synapse.nix
        ./modules/umami.nix
        ./modules/wiki-js.nix
        ./modules/caddy/hetzner.nix
        ./hosts/hetzner
      ];
    };

    hetzner-core = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
      };
      modules = [
        basicModules
        inputs.authentik-nix.nixosModules.default

        ./home/bukun.nix
        ./home/root.nix
        ./modules/auto-upgrade-slowring.nix
        ./modules/openssh.nix
        ./modules/ssh-totp-auth.nix
        ./modules/uptime-kuma.nix
        ./modules/ntfy.nix
        ./modules/caddy/hetzner-core.nix
        ./hosts/hetzner-core
      ];
    };
  };
}
