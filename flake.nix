{
  description = "development environment NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aquamarine.url = "github:hyprwm/aquamarine";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland.inputs.aquamarine.follows = "aquamarine";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, rust-overlay, nil, eww, nix-gaming, ... }@inputs:

  # NOTE: set these to whatever is relevant for your system!
  let
  settings = {
    system = "x86_64-linux";
    hostname = "nixos";
    user = "ses";
    timezone = "America/New_York";
    locale =  "en_US.UTF-8";
    boot_mode = "uefi"; # uefi, bios
    boot_mount_path = "/boot";
    grub_device = "";
    is_asus = true; # true, false
    gpu = {
      type = "amdgpu"; # amdgpu, nvidia, intel
      # PCI bus IDs for GPU management
      # needed if wanna use NVIDIA prime,
      # dont need it otherwise 
      bus_ids = {
        amdgpu = "PCI:4:0:0";
        nvidia = "PCI:1:0:0";
        intel = "";
      };
    };
  };
  pkgs = import nixpkgs {
	  config.allowUnfree = true;
    overlays = [ rust-overlay.overlays.default ];
  };
  lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      ${settings.hostname} = lib.nixosSystem rec {
        system = settings.system;
        specialArgs = {
          inherit settings;
          inherit hyprland;
        };
        modules = [ 
          ./nixos/configuration.nix
          hyprland.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${settings.user} = import ./home/home.nix;
            home-manager.extraSpecialArgs = specialArgs;
          }
        ];
      };
    };
  };
}

