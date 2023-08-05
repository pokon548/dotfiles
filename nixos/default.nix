{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    ./common.nix
    ./surfacego.nix
    
    ./services/dae.nix
  ];
}
