{ config, pkgs, nixpkgs-unstable, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../modules/splashscreen.nix

    ../modules/openssh.nix
    ../modules/xserver.nix
    ../modules/intel.nix
    ../modules/audio.nix
  ];

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/swap".options = [ "noatime" ];
  };

  swapDevices = [{
    device = "/swap/swapfile";
    size = 64*1024;
  }];

  services.power-profiles-daemon.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  networking = {
    hostName = "nixos-mtrybus";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 80 ];
  };

  services.udisks2.enable = true;

  services.printing.enable = true;

  services.lighttpd = {
    enable = true;
    document-root = "/var/www";
  };

  system.stateVersion = "25.05";
}
