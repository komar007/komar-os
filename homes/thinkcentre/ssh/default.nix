{ config, ... }:
let
  utils = import ../../modules/ssh/utils.nix { };
in
{
  home.file.".ssh/id_rsa.pub".source = ./ssh_id;
  home.file.".ssh/id_rsa".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  programs.ssh.matchBlocks.work-pc = {
    host = "work-vpn";
    hostname = "192.168.134.42";
    proxyJump = "adb-jumphost";
    port = 22;
    user = "komar";
    forwardX11 = true;
  };
  programs.ssh.matchBlocks.adb-jumphost = {
    host = "adb-jumphost";
    hostname = "192.168.5.68";
    port = 22;
    user = "M.Trybus";
  };
  programs.ssh.matchBlocks.work-pc-tunnel = {
    host = "work";
    hostname = "localhost";
    port = 9022;
    user = "komar";
    forwardX11 = true;
  };

  ssh.authorizedKeys = [
    (utils.ssh-pub-key-for "framework")
    (utils.ssh-pub-key-for "work")
    (builtins.readFile ./kpiano_ssh_id)
  ];
}
