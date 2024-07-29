{ settings, config, lib, pkgs, nix-gaming, ... }:

{
  home.packages = with pkgs; [ 
    nix-gaming.${setttings.system}.wine-ge
  ];
}
