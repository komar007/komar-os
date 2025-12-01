{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../modules/grub2.nix
    ../modules/splashscreen.nix

    ../modules/openssh.nix
    ../modules/xserver.nix
    ../modules/intel.nix
    ../modules/audio.nix
  ];

  boot.loader.grub2-theme.customResolution = "3840x2160";

  services.power-profiles-daemon.enable = true;

  services.logind.settings.Login = {
    HandlePowerKey = "hibernate";
  };

  services.xserver.videoDrivers = [ "modesetting" ];

  systemd =
    let
      reconnect-bt = pkgs.writeShellScriptBin "reconnect-bt" ''
        BT="${pkgs.bluez}/bin/bluetoothctl"
        for _ in $(seq 10); do
          if [ "$("$BT" list | wc -l)" -gt 0 ]; then
            for dev in $("$BT" devices Trusted | cut -d' ' -f2); do
              "$BT" -t1 connect "$dev"
            done
            echo "attempted to reconnect trusted bluetooth devices"
            exit
          fi
          sleep 1
        done
        echo "failed to reconnect trusted bluetooth devices, no controller"
      '';
    in
    {
      user.services.connect-bt = {
        description = "Connect trusted Bluetooth devices";
        wantedBy = [ "pipewire.service" ];
        after = [ "pipewire.service" ];
        serviceConfig.Type = "oneshot";
        script = "${pkgs.lib.getExe reconnect-bt}";
      };
      services.reconnect-bt = {
        description = "Reconnect trusted Bluetooth devices";
        wantedBy = [ "post-resume.target" ];
        after = [ "post-resume.target" ];
        serviceConfig.Type = "oneshot";
        script = "${pkgs.lib.getExe reconnect-bt}";
      };
    };

  networking = {
    hostName = "nixos-thnkctre";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 80 ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.udisks2.enable = true;

  services.printing.enable = true;

  services.lighttpd = {
    enable = true;
    document-root = "/var/www";
  };

  programs.virt-manager.enable = true;
  users.users.komar.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  system.stateVersion = "23.11";
}
