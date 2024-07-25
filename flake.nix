{
  description = "development environment NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }:

  let settings = {
    system = "x86_64-linux";
    hostname = "nixos";
    timezone = "America/New_York";
    locale =  "en_US.UTF-8";
    boot_mode = "uefi";
    boot_mount_path = "/boot";
    grub_device = "";
  };
  pkgs = import nixpkgs {
	  config.allowUnfree = true;
  };
  lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      ses = lib.nixosSystem rec {
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
            home-manager.users.ses = import ./home/home.nix;
            home-manager.extraSpecialArgs = specialArgs;
          }
        ];
      };
    };
  };
}
