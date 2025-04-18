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
    "nixos-config=/home/${settings.user}/shared/repos/nixos-flake/nixos/configuration.nix"
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

  # for virtualisation
  boot.kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      "default_hugepagesz=2M"
      "hugepagesz=2M"
      "hugepages=8600"
    ];

  boot.kernelModules = [ "vfio-pci" "vfio" "vfio-iommu-type1" "kvm-amd" ];

  # Load GPU drivers right away
  boot.initrd.kernelModules = if (settings.gpu.type == "intel")
      then [ "modesetting" ]
      else [ settings.gpu.type ];

  # AMD specific power optimisations (part of xanmod kernel patches)
  boot.extraModulePackages = with config.boot.kernelPackages; [ zenpower ];

  # Dont load open source nvidia drivers -- broken
  # https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Bluescreen_at_boot_since_Windows_10_1803
  # Bluescreen at boot since Windows 10 1803
  # Since Windows 10 1803 there is a problem when you are using "host-passthrough" as cpu model.
  # The machine cannot boot and is either boot looping or you get a bluescreen.
  # You can workaround this by:
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
    options kvm ignore_msrs=1 report_ignored_msrs=0
    options vfio-pci ids=10de:2520,10de:228e
  '';
  # had before:

  # Don't load normal nvidia gpu drivers...
  # Integrated graphics is enough for now,
  # and I will usually keep vfio drivers loaded,
  # so I can use the GPU completely for the Win10/Win11 testing VMS
  boot.blacklistedKernelModules = [ "nouveau" ]; # add "nvidia_modeset" for no power management
  
  # Define your hostname.
  networking.hostName = settings.hostname;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable physical netwrk interface to use as vm network bridge
  # networking.bridges.br-lan.interfaces = [ "eno2" ];
  
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
    videoDrivers = if (settings.gpu.type == "intel")
      then [ "modesetting" ]
      else [ settings.gpu.type ];
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
  services.getty.autologinUser = settings.user;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${settings.user} = {
    isNormalUser = true;
    description = settings.user;
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
    packages = with pkgs; [
      
    ];
  };

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    package = pkgs.libvirt;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        runAsRoot = true;
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
        verbatimConfig = ''
          namespaces = []
          user = "${settings.user}"
          group = "kvm"
          cgroup_device_acl = [
            "/dev/input/by-id/usb-ASUSTeK_Computer_Inc._N-KEY_Device-if02-event-kbd",
            "/dev/input/by-id/usb-HP__Inc_HyperX_Pulsefire_Haste_Wireless-event-mouse",
            "/dev/tpm0",
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
            "/dev/rtc","/dev/hpet", "/dev/sev"
          ]
          unix_sock_group = "libvirt"
          unix_sock_ro_perms = "0777"
          unix_sock_rw_perms = "0770"
          unix_sock_admin_perms = "0700"
        '';
      };
  };

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    git
    vim
    fastfetch
    libevdev
    pciutils
    libguestfs
    win-virtio
    virtiofsd
    qemu
    tpm2-tss
  ];

  # cpu power management
  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

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
    # platformOptimizations.enable = true;
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
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # Enable xrdp
  services.xrdp.enable = true; # use remote_logout and remote_unlock
  services.xrdp.defaultWindowManager = "hyprland";
  systemd.sockets.pcscd.enable = false;

  # Asus laptop helper services, can comment out if not using an ASUS laptop
  services = {
    asusd = {
      enable = settings.is_asus;
      enableUserService = true;
    };
  };
  # Allows hotswapping VFIO gpu drivers on ASUS laptops for KVM
  services.supergfxd.enable = settings.is_asus;
  systemd = {
  tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
    services = {
  pcscd.enable = false;

    supergfxd.path = if (settings.is_asus)
      then [ pkgs.pciutils ]
      else [];
    
# Add binaries to path so that hooks can use it
  libvirtd = {
    path = let
             env = pkgs.buildEnv {
               name = "qemu-hook-env";
               paths = with pkgs; [
                 bash
                 libvirt
                 kmod
                 systemd
                 ripgrep
                 sd
               ];
             };
           in
           [ env ];

    preStart =
    ''
      mkdir -p /var/lib/libvirt/hooks
      mkdir -p /var/lib/libvirt/hooks/qemu.d/win11/prepare/begin
      mkdir -p /var/lib/libvirt/hooks/qemu.d/win11/release/end
      mkdir -p /var/lib/libvirt/vgabios
      
      # ln -sf /home/${settings.user}/shared/symlinks/qemu /var/lib/libvirt/hooks/qemu
      # ln -sf /home/${settings.user}/shared/symlinks/kvm.conf /var/lib/libvirt/hooks/kvm.conf
      # ln -sf /home/${settings.user}/shared/symlinks/start.sh /var/lib/libvirt/hooks/qemu.d/win11/prepare/begin/start.sh
      # ln -sf /home/${settings.user}/shared/symlinks/stop.sh /var/lib/libvirt/hooks/qemu.d/win11/release/end/stop.sh
      # ln -sf /home/${settings.user}/shared/symlinks/patched.rom /var/lib/libvirt/vgabios/patched.rom

      cp -f /home/${settings.user}/shared/symlinks/qemu /var/lib/libvirt/hooks/qemu
      cp -f /home/${settings.user}/shared/symlinks/kvm.conf /var/lib/libvirt/hooks/kvm.conf
      cp -f /home/${settings.user}/shared/symlinks/start.sh /var/lib/libvirt/hooks/qemu.d/win11/prepare/begin/start.sh
      cp -f /home/${settings.user}/shared/symlinks/stop.sh /var/lib/libvirt/hooks/qemu.d/win11/release/end/stop.sh
      cp -f /home/${settings.user}/shared/symlinks/patched.rom /var/lib/libvirt/vgabios/patched.rom
      
      chmod +x /var/lib/libvirt/hooks/qemu
      chmod +x /var/lib/libvirt/hooks/kvm.conf
      chmod +x /var/lib/libvirt/hooks/qemu.d/win11/prepare/begin/start.sh
      chmod +x /var/lib/libvirt/hooks/qemu.d/win11/release/end/stop.sh
    '';
  };

    
  };
  };

  # power management and performance optmisations for asus ROG laptops
  programs.rog-control-center = {
    enable = settings.is_asus;
    autoStart = true;
  };

  programs.bash.interactiveShellInit = 
     ''
        if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
          #prevents cursor disappear when using Nvidia drivers
          Exec=env WLR_NO_HARDWARE_CURSORS=1 Hyprland
        fi
      '';

  # List services that you want to enable:
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; {
        "amdgpu" = [ amdvlk ];
        "nvidia" = [];
        "intel" = [];
      }.${settings.gpu.type}
      ++ [ pkgs.rocmPackages.clr.icd ];

      extraPackages32 = with pkgs; {
        "amdgpu" =  [ driversi686Linux.amdvlk ];
        "nvidia" = [];
        "intel" = [];
      }.${settings.gpu.type};
    };

    # force proprietary nvidia drivers
    nvidia = if (settings.gpu.type != "nvidia") then {} else {
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      prime = {
        allowExternalGpu = true;
        offload.enable = true;
        # Apply PCI bus IDs from settings.gpu.bus_ids
        # need at least 2 for prime switching to work
        nvidiaBusId = settings.gpu.bus_ids.nvidia;
        amdgpuBusId = settings.gpu.bus_ids.amdgpu;
        intelBusId = settings.gpu.bus_ids.intel;
      };
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
