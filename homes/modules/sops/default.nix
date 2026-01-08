{ configuration-name, sops-nix, ... }:
{
  imports = [
    sops-nix.homeManagerModules.sops
  ];

  sops = {
    defaultSopsFile = ../../${configuration-name}/secrets.yaml;
    # sops-nix asserts without any key source, but it does not know that sops-install-secrets can
    # in fact use the user ssh key in a standard path, so we add a dummy...
    age.sshKeyPaths = [ "/not/needed" ];
  };
}
