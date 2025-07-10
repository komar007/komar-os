{ lib, pkgs, ... }: {
  programs.ssh = {
    enable = true;

    serverAliveInterval = 100;
    serverAliveCountMax = 3;
  };
}
