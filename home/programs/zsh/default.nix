{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      icat = "kitten icat";
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };
  };
}
