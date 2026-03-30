{ config, ... }:
let
  utils = import ../../modules/ssh/utils.nix { };
in
{
  imports = [
    ./hosts.nix
  ];

  home.file.".ssh/id_rsa.pub".source = ./ssh_id;
  home.file.".ssh/id_rsa".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  ssh.authorizedKeys = [
    (utils.ssh-pub-key-for "framework")
    (utils.ssh-pub-key-for "thinkcentre")
  ];
}
