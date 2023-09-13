{ self, inputs, ... }: {
  perSystem = { config, pkgs, lib, ... }:
    let
      homeManagerConfiguration = { extraModules ? [ ] }:
        (inputs.home-manager.lib.homeManagerConfiguration {
          modules = [
            {
              _module.args.self = self;
              _module.args.inputs = self.inputs;
              imports =
                extraModules
                ++ [
                  ./common.nix
                  inputs.nix-index-database.hmModules.nix-index
                ];
            }
          ];
          inherit pkgs;
        });
    in
    {
      legacyPackages = {
        homeConfigurations = {
          common = homeManagerConfiguration { };
        } // lib.optionalAttrs (pkgs.hostPlatform.system == "x86_64-linux") {
          desktop = homeManagerConfiguration {
            extraModules = [ ./modules/gnome.nix ./modules/librewolf.nix ./modules/ohmyzsh.nix ./modules/vscode.nix ];
          };

          # different username
          pokon548 = homeManagerConfiguration {
            extraModules = [{ home.username = "pokon548"; } ./pokon548.nix ];
          };
        };
      };
    };
}
