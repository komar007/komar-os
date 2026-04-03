{
  configurationName,
  config,
  pkgs,
  inputs,
  ...
}:
let
  utils = import ./utils.nix { };
  # This env makes both sops and sops-install-secrets from sops-nix work on ssh ed25519 keys
  # directly, instead of relying on age keys converted from ssh keys.
  sopsAgeSshPrivateKeyFile = "/etc/ssh/ssh_host_ed25519_key";
  wrappedSops = pkgs.symlinkJoin {
    name = "sops";
    paths = [ pkgs.sops ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/sops \
        --set EDITOR ${pkgs.lib.getExe pkgs.neovim} \
        --set SOPS_AGE_SSH_PRIVATE_KEY_FILE ${sopsAgeSshPrivateKeyFile}
    '';
  };
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    environment = {
      SOPS_AGE_SSH_PRIVATE_KEY_FILE = sopsAgeSshPrivateKeyFile;
    };
    defaultSopsFile = ../../${configurationName}/secrets.yaml;
    secrets =
      let
        komar = config.users.users.komar.name;
      in
      {
        "users/${komar}/ssh_key" = utils.justFor komar;
      };
  };

  environment.systemPackages = [
    wrappedSops
  ];
}
