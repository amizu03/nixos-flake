{ hyprland, pkgs, ...}: {

  imports = [
    hyprland.homeManagerModules.default
    ./programs
  ];

  home = {
    username = "ses";
    homeDirectory = "/home/ses";
  };

  home.packages = (with pkgs; [
    # console utils
    fastfetch
      # utils
      vesktop
      telegram-desktop
      kitty
      warp-terminal
      spotify
      firefox
      flameshot
      authenticator
      obs-studio
    # Programming-related
      wget
      unzip
      git
      gdb
      gcc
      cmake
      python3 
      rustup
      jq
    # # wine
    # # support both 32- and 64-bit applications
    # #wineWowPackages.stable
    # # support 32-bit only
    # #wine
    # # support 64-bit only
    # #(wine.override { wineBuild = "wine64"; })
    # # support 64-bit only
    # #wine64
    # # wine-staging (version with experimental features)
    # wineWowPackages.staging
    # # winetricks (all versions)
    # #winetricks
    # # native wayland support (unstable)
    # wineWowPackages.waylandFull
    meson
    brightnessctl
    ranger
    pavucontrol  
    playerctl
    # command line utils
    pciutils
    # notification library
      # misc
      wmctrl
      curl
      wlr-randr
      appimage-run
      dunst
      neovim
      #waybar
      eww
      swww
      wayland-utils
      wl-clipboard
      wlroots
      xdg-utils
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xwayland
      hyprland
      tokyo-night-gtk
      rofi-wayland
      wl-clipboard
      pamixer
      tty-clock
      btop
  ]) ++ (with pkgs.gnome; [ 
    zenity
    gnome-tweaks
  ]);

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "tokyo-night-gtk";
    };
  };

  programs.home-manager.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "tokyo-night-gtk";
      package = pkgs.tokyo-night-gtk;
    };
  };

  home.stateVersion = "24.05";
}
