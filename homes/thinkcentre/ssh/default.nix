{ config, ... }:
let
  utils = import ../../modules/ssh/utils.nix { };
  workMatchBlock = import ../../work/ssh/matchblock.nix;
  adbJumphost = {
    host = "adb-jumphost";
    hostname = "192.168.5.68";
    port = 22;
    user = "M.Trybus";
  };
in
{
  home.file.".ssh/id_rsa.pub".source = ./ssh_id;
  home.file.".ssh/id_rsa".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  programs.ssh.matchBlocks.work-pc = {
    host = "work-vpn";
    hostname = "192.168.134.42";
    proxyJump = adbJumphost.host;
    port = 22;
    user = "komar";
    forwardX11 = true;
  };
  programs.ssh.matchBlocks.adb-jumphost = adbJumphost;
  programs.ssh.matchBlocks.work-pc-tunnel = workMatchBlock // {
    host = "work";
  };
  programs.ssh.matchBlocks.voron = {
    host = "voron";
    hostname = "192.168.88.94";
    user = "biqu";
  };

  ssh.authorizedKeys = [
    (utils.sshPubKeyFor "framework")
    (utils.sshPubKeyFor "work")
    (builtins.readFile ./kpiano_ssh_id)
  ];
}
