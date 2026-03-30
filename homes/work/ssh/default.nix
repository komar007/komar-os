{ config, ... }:
let
  utils = import ../../modules/ssh/utils.nix { };
  p = config.sops.placeholder;
in
{
  home.file.".ssh/id_rsa.pub".source = ./ssh_id;
  home.file.".ssh/id_rsa".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  ssh.authorizedKeys = [
    (utils.ssh-pub-key-for "framework")
    (utils.ssh-pub-key-for "thinkcentre")
  ];

  sops.secrets."public_addr/thinkcentre" = { };
  sops.secrets."public_addr/adb_devs" = { };
  sops.secrets."public_addr/prisme_integration" = { };
  sops.secrets."public_addr/prisme_nightly" = { };

  sops-anything.home-files = [
    ".ssh/config"
  ];

  programs.ssh.matchBlocks.thinkcentre-tunnel = {
    host = "thinkcentre-tunnel";
    hostname = "${p."public_addr/thinkcentre"}";
    port = 2022;
    user = "komar";
    serverAliveInterval = 30;
    serverAliveCountMax = 3;
    remoteForwards = [
      {
        bind.port = 9022;
        host.address = "localhost";
        host.port = 22;
      }
    ];
    extraOptions = {
      "ExitOnForwardFailure" = "yes";
      "RemoteForward" = "9999"; # cannot be done using remoteForwards, host cannot be null
    };
  };

  programs.ssh.matchBlocks.adb-devs = {
    host = "${p."public_addr/adb_devs"}";
    hostname = "${p."public_addr/adb_devs"}";
    user = "M.Trybus";
  };

  programs.ssh.matchBlocks.prisme_integration = {
    host = "integration";
    hostname = "${p."public_addr/prisme_integration"}";
    port = 2222;
    user = "adb-users";
    serverAliveInterval = 5;
  };

  programs.ssh.matchBlocks.prisme_nightly = {
    host = "nightly";
    hostname = "${p."public_addr/prisme_nightly"}";
    port = 2222;
    user = "adb-admins";
    serverAliveInterval = 5;
  };
}
