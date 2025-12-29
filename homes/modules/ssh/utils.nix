{ ... }:
{
  # The SSH public key for configuration 'name'
  ssh-pub-key-for = name: (builtins.readFile ../../${name}/ssh/ssh_id);
}
