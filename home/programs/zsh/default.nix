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

  home.file.".zshrc".text = ''
#export PATH=$HOME/bin:/usr/local/bin:"$PATH"

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt beep
bindkey -e

#printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'
  '';
}
