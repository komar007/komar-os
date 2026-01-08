{ config, ... }:
{
  home.file.".ssh/id_ed25519.pub".source = ./ssh_id;
  home.file.".ssh/id_ed25519".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  programs.ssh.matchBlocks.thinkcentre = {
    host = "thinkcentre";
    hostname = "192.168.88.2";
    port = 22;
    user = "komar";
    forwardX11 = true;
  };

  programs.ssh.matchBlocks.work-via-thinkcentre = {
    host = "work-via-thinkcentre";
    proxyJump = "thinkcentre";
    hostname = "localhost";
    port = 9022;
    user = "komar";
    forwardX11 = true;
  };
}
