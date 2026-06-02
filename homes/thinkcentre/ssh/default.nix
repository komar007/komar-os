{ config, ... }:
let
  utils = import ../../modules/ssh/utils.nix { };
in
{
  home.file.".ssh/id_rsa.pub".source = ./ssh_id;
  home.file.".ssh/id_rsa".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  programs.ssh.settings.work-vpn = {
    HostName = "192.168.134.42";
    ProxyJump = "adb-jumphost";
    Port = 22;
    User = "komar";
    ForwardX11 = true;
  };
  programs.ssh.settings.adb-jumphost = {
    HostName = "192.168.5.68";
    Port = 22;
    User = "M.Trybus";
  };
  programs.ssh.settings.work = import ../../work/ssh/matchblock.nix;
  programs.ssh.settings.voron = {
    HostName = "192.168.88.94";
    User = "biqu";
  };

  ssh.authorizedKeys = [
    (utils.sshPubKeyFor "framework")
    (utils.sshPubKeyFor "work")
    (builtins.readFile ./kpiano_ssh_id)
  ];
}
