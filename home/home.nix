{ settings, hyprland, pkgs, ...}: {

  imports = [
    hyprland.homeManagerModules.default
    ./programs
  ];

  home = {
    username = settings.user;
    homeDirectory = "/home/${settings.user}";
  };

  home.packages = with pkgs; [
  # Programming-related
      # overlays.rust-bin.nightly.latest.default
      cargo-generate
      wget
      unzip
      gdb
      gcc
      cmake
      python3 
      nil # Nix LSP
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
      # dwm stuff
      dunst
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
      virt-manager
      # utils
      vesktop
      telegram-desktop
      kitty
      spotify
      firefox
      flameshot
      authenticator
      obs-studio
      ghidra-bin
      # p
      appimage-run
      neovim
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

  # Make QT applications look similar to GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "gtk3";
  };
  
  programs.home-manager.enable = true;
  
  # Autostart hyprland on login
  home.stateVersion = "24.11";
}
