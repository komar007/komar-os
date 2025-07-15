{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../modules/splashscreen.nix

    ../modules/sops

    ../modules/openssh.nix
    ../modules/xserver.nix
    ../modules/intel.nix
    ../modules/audio.nix
    ../modules/maintain-ssh-connection
  ];

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
    "/swap".options = [ "noatime" ];
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 64 * 1024;
    }
  ];

  services.power-profiles-daemon.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  networking = {
    hostName = "nixos-mtrybus";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 80 ];
  };

  maintain-ssh-connection.user = "komar";
  maintain-ssh-connection.host = "thinkcentre-tunnel";

  services.udisks2.enable = true;

  services.printing.enable = true;

  services.lighttpd = {
    enable = true;
    document-root = "/var/www";
  };

  virtualisation.docker.rootless.daemon.settings = {
    bip = "10.9.1.5/24";
    default-address-pools = [
      {
        base = "10.10.0.0/16";
        size = 24;
      }
    ];
  };

  system.stateVersion = "25.05";
}
