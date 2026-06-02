{ config, ... }:
let
  thinkcentre = {
    HostName = "192.168.88.2";
    Port = 22;
    User = "komar";
    ForwardX11 = true;
    ForwardX11Trusted = true;
  };
in
{
  home.file.".ssh/id_ed25519.pub".source = ./ssh_id;
  home.file.".ssh/id_ed25519".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  programs.ssh.settings.thinkcentre = thinkcentre;
  programs.ssh.settings.work-via-thinkcentre = import ../../work/ssh/matchblock.nix // {
    ProxyJump = "thinkcentre";
  };
  programs.ssh.settings.voron = {
    HostName = "192.168.88.94";
    User = "biqu";
  };
}
