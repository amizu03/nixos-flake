{ config, lib, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    proggyfonts
    nerdfonts
    meslo-lgs-nf
  ];
}

