{ ... }:
{
  # The SSH public key for configuration 'name'
  sshPubKeyFor = name: (builtins.readFile ../../${name}/ssh/ssh_id);
}
