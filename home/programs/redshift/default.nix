{ config, lib, pkgs, rust-overlay, ... }:

{
  location.latitude = 40.730610;
  location.longitude -73.935242;

  services.redshift = {
    enable = true;
    brightness = {
      # Note the string values below.
      day = "1";
      night = "1";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
  };
}
