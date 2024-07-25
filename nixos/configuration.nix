{ config, pkgs, lib, ... }:

{
  imports =
    [
    # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Desktop environment
      ../desktop
    ];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.loader.grub = {
    enable = true;
    devices = [ "nodev" ];
    efiInstallAsRemovable = true;
    efiSupport = true;
    useOSProber = true;
  };

  # Dont load open source nvidia drivers -- broken
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  # Don't load normal nvidia gpu drivers...
  # Integrated graphics is enough for now,
  # and I will usually keep vfio drivers loaded,
  # so I can use the GPU completely for the Win10/Win11 testing VMS
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];
  
  # Define your hostname.
  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    # videoDrivers = [ "nvidia" ];
    # displayManager.startx.enable = true;
    xkb = {
      # Set keyboard layout
      layout = "us";
      variant = "";
      # Might wanna change this depending on the computer
      options = "grp:win_space_toggle";
    };
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "ses";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ses = {
    isNormalUser = true;
    description = "ses";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.pathsToLink = [ "/share/zsh" ];

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    git
    vim
    fastfetch
    libevdev
    pciutils
  ];

  # System-wide ame mode optimisations, really cool
  # https://wiki.nixos.org/wiki/GameMode
  programs.gamemode.enable = true;
  programs.rog-control-center.enable = true;

  # Steam
  # NOTE: should probably not install this System-wide
  # instead, install for local user only maybe?
  # im not sure if game mode will still work then or anything else will break. will try later.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Sound setup
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # Some default environment variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # WLR_RENDERER_ALLOW_SOFTWARE = "1";
    NIXOS_OZONE_WL = "1";
  };
  
  # Asus laptop helper services, can comment out if not using an ASUS laptop
  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };
  # Allows hotswapping VFIO gpu drivers on ASUS laptops for KVM
  services.supergfxd.enable = true;
  systemd.services.supergfxd.path = [ pkgs.pciutils ];

  # List services that you want to enable:
  # services.xserver.
  
  hardware = {
    # force integrated amd gpu to use vulkan drivers
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
    # force proprietary nvidia drivers
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Delete old nixos builds (> 1 week)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Use NixOS unstable branch
  # If want to change nixos version we can do that here
  system.autoUpgrade = {
   enable = true;
   channel = "https://nixos.org/channels/nixos-unstable";
  };

  # Version info
  system.stateVersion = "24.05"; # Did you read the comment?

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
