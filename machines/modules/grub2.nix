{ lib, grub-themes-module, ... }:
{
  imports = [
    grub-themes-module
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 5;
  };
  boot.loader.grub2-theme = {
    enable = true;
    theme = "stylish";
  };
}
