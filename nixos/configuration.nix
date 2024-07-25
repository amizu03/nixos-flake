{ settings, config, pkgs, lib, ... }:

{
  imports =
    [
    # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Desktop environment
      ../desktop
    ];

  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
    "nixos-config=$HOME/shared/repos/nixos-flake/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  # Bootloader
  # https://github.com/librephoenix/nixos-config/blob/5570e49412301ac34cb5e7d2806aae9ec9116195/profiles/homelab/base.nix#L33C1-L37C103
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.loader.systemd-boot.enable = settings.boot_mode == "uefi";
  boot.loader.efi.canTouchEfiVariables = settings.boot_mode == "uefi";
  boot.loader.efi.efiSysMountPoint = settings.boot_mount_path; # does nothing if running bios rather than uefi
  boot.loader.grub.enable = settings.boot_mode != "uefi";
  boot.loader.grub.device = settings.grub_device; # does nothing if running uefi rather than bios

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
  networking.hostName = settings.hostname;

  # Enable networking
  networking.networkmanager.enable = true;
  
  # Set your time zone.
  time.timeZone = settings.timezone;

  # Select internationalisation properties.
  i18n.defaultLocale = settings.locale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = settings.locale;
    LC_IDENTIFICATION = settings.locale;
    LC_MEASUREMENT = settings.locale;
    LC_MONETARY = settings.locale;
    LC_NAME = settings.locale;
    LC_NUMERIC = settings.locale;
    LC_PAPER = settings.locale;
    LC_TELEPHONE = settings.locale;
    LC_TIME = settings.locale;
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    # videoDrivers = [ "nvidia" ];
    displayManager.startx.enable = true;
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

  nixpkgs.config.allowUnfree = true;

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
      enable = settings.is_asus;
      enableUserService = true;
    };
  };
  # Allows hotswapping VFIO gpu drivers on ASUS laptops for KVM
  services.supergfxd.enable = settings.is_asus;
  systemd.services.supergfxd.path = if (settings.is_asus) then [ pkgs.pciutils ] else [];

  # power management and performance optmisations for asus ROG laptops
  programs.rog-control-center = {
    enable = settings.is_asus;
    autoStart = true;
  };

  # List services that you want to enable:
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        {
          "amd" = amdvlk;
        }.${settings.gpu_type}
      ];
      extraPackages32 = with pkgs; [
        {
          "amd" =  driversi686Linux.amdvlk;
        }.${settings.gpu_type}
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
  system.stateVersion = "24.11"; # Did you read the comment?

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
