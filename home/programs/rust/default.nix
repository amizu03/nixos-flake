{ config, lib, pkgs, rust-overlay, ... }:

{
  #home.packages = pkgs.overlays.rust-bin.stable.latest.default;
}
