# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  # boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4150bf8f-71b3-4b9f-a188-e35dead61bb4";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-30e5df54-16ce-421f-a8e6-738559d273a7".device = "/dev/disk/by-uuid/30e5df54-16ce-421f-a8e6-738559d273a7";
  boot.initrd.luks.devices."luks-edab255e-4005-402b-bc19-029517e38898".device = "/dev/disk/by-uuid/edab255e-4005-402b-bc19-029517e38898";
  
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0BE8-6E53";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9079cf3b-f7fe-4107-b6ec-351714f65362"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
