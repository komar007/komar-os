{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s.enable = true;
  services.k3s = {
    role = "server";
    extraFlags = [
      "--write-kubeconfig-mode 640"
      "--write-kubeconfig-group k3sconfig"
    ];
  };
  users.groups.k3sconfig = { };
  users.users.komar.extraGroups = [ "k3sconfig" ];
}
