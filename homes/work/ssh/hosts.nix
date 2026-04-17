{ config, ... }:
let
  p = config.sops.placeholder;
in
{
  sops.secrets."public_addr/thinkcentre" = { };
  programs.ssh.matchBlocks.thinkcentre-tunnel = {
    host = "thinkcentre-tunnel";
    hostname = "${p."public_addr/thinkcentre"}";
    port = 2022;
    user = "komar";
    serverAliveInterval = 30;
    serverAliveCountMax = 3;
    remoteForwards = [
      {
        bind.port = (import ./matchblock.nix).port;
        host.address = "localhost";
        host.port = 22;
      }
    ];
    extraOptions = {
      "ExitOnForwardFailure" = "yes";
      "RemoteForward" = "9999"; # cannot be done using remoteForwards, host cannot be null
    };
  };

  sops.secrets."public_addr/adb_devs" = { };
  programs.ssh.matchBlocks.adb-devs = {
    host = "${p."public_addr/adb_devs"}";
    hostname = "${p."public_addr/adb_devs"}";
    user = "M.Trybus";
  };

  sops.secrets."public_addr/prisme_integration" = { };
  programs.ssh.matchBlocks.prisme_integration = {
    host = "integration";
    hostname = "${p."public_addr/prisme_integration"}";
    port = 2222;
    user = "adb-users";
    serverAliveInterval = 5;
  };

  sops.secrets."public_addr/prisme_nightly" = { };
  programs.ssh.matchBlocks.prisme_nightly = {
    host = "nightly";
    hostname = "${p."public_addr/prisme_nightly"}";
    port = 2222;
    user = "adb-admins";
    serverAliveInterval = 5;
  };
}
