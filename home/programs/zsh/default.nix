{ settings, config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      icat = "kitten icat";
      ll = "ls -l";
      nix-clean = "nix-store --gc && nix-collect-garbage -d";
      nix-update = "(cd ~/shared/repos/nixos-flake/; git pull && sudo nixos-rebuild switch --flake .#${settings.user} --show-trace)";
      gpu-info = "lspci | grep ' VGA ' | cut -d\" \" -f 1 | xargs -i lspci -v -s {}";
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
