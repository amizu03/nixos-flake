{ config, lib, pkgs, rust-overlay, ... }:

{
  programs.looking-glass-client = {
    enable = true;

    settings = {
      app = {
      allowDMA = true;
      shmFile = "/dev/shm/looking-glass";
    };

  win = {
    fullScreen = true;
    showFPS = false;
    jitRender = true;
  };

  spice = {
    enable = true;
    audio = true;
  };

  input = {
    rawMouse = true;
    # escapeKey = 62;
  };
  };
};
}
