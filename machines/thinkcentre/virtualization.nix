{ ... }:
{
  programs.virt-manager.enable = true;
  users.users.komar.extraGroups = [ "libvirtd" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
