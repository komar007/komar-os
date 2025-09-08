{ config, pkgs, nixpkgs-unstable, ...}: {
  services.openssh.enable = true;

  services.openssh.settings = {
    ClientAliveInterval = 15;
    ClientAliveCountMax = 3;
    X11Forwarding = true;
  };
}
