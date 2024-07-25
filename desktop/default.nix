{ config, lib, pkgs, ... }:
{
  imports = [
    ./fonts
  ];

  programs.dconf.enable = true;

  xdg = {
    autostart.enable = true;
    portal = {
      config.common.default = "*";
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
