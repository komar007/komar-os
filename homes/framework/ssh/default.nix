{ config, ... }:
let
  workMatchBlock = import ../../work/ssh/matchblock.nix;
  thinkcentre = {
    host = "thinkcentre";
    hostname = "192.168.88.2";
    port = 22;
    user = "komar";
    forwardX11 = true;
  };
in
{
  home.file.".ssh/id_ed25519.pub".source = ./ssh_id;
  home.file.".ssh/id_ed25519".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  programs.ssh.matchBlocks.thinkcentre = thinkcentre;
  programs.ssh.matchBlocks.work-via-thinkcentre = workMatchBlock // {
    host = "work-via-thinkcentre";
    proxyJump = thinkcentre.host;
  };
  programs.ssh.matchBlocks.voron = {
    host = "voron";
    hostname = "192.168.88.94";
    user = "biqu";
  };
}
