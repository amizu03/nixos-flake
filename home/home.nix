{ settings, hyprland, pkgs, ...}: {

  imports = [
    hyprland.homeManagerModules.default
    ./programs
  ];

  home = {
    username = settings.user;
    homeDirectory = "/home/${settings.user}";
  };

  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # WLR_RENDERER_ALLOW_SOFTWARE = "1";
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    virt-manager
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
      gdb
      gcc
      cmake
      python3 
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
    # notification library
      # misc
      wmctrl
      curl
      wlr-randr
      appimage-run
      dunst
      neovim
    # dwm stuff
      wayland-utils
      wl-clipboard
      wlroots
      xdg-utils
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xwayland
      # hyprland
      tokyo-night-gtk
      rofi-wayland
      wl-clipboard
      pamixer
      tty-clock
      btop
      p7zip
      gnome-tweaks
      # rog-control-center
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "tokyo-night-gtk";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "tokyo-night-gtk";
      package = pkgs.tokyo-night-gtk;
    };
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
