{
  configuration-name,
  config,
  pkgs,
  sops-pkgs,
  sops-nix,
  ...
}:
let
  # This env makes both sops and sops-install-secrets from sops-nix work on ssh ed25519 keys
  # directly, instead of relying on age keys converted from ssh keys.
  env-set-ssh-host-key = "SOPS_AGE_SSH_PRIVATE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key";
  utils = import ./utils.nix { };
in
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    package = pkgs.writeShellApplication {
      name = "sops-install-secrets";
      runtimeInputs = [ sops-pkgs.sops-install-secrets ];
      text = ''
        ${env-set-ssh-host-key} sops-install-secrets "$@"
      '';
    };
    defaultSopsFile = ../../${configuration-name}/secrets.yaml;
    secrets =
      let
        komar = config.users.users.komar.name;
      in
      {
        "users/${komar}/ssh_key" = utils.just_for komar;
      };
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "sops";
      runtimeInputs = [ pkgs.sops ];
      text = ''
        EDITOR=nvim ${env-set-ssh-host-key} sops "$@"
      '';
    })
  ];
}
