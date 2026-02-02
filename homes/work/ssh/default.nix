{ config, ... }:
let
  utils = import ../../modules/ssh/utils.nix { };
  p = config.sops.placeholder;
in
{
  home.file.".ssh/id_rsa.pub".source = ./ssh_id;
  home.file.".ssh/id_rsa".source =
    config.lib.file.mkOutOfStoreSymlink "/run/secrets/users/${config.home.username}/ssh_key";

  programs.ssh.includes = [
    config.sops.templates."ssh/hosts".path
  ];

  ssh.authorizedKeys = [
    (utils.ssh-pub-key-for "framework")
    (utils.ssh-pub-key-for "thinkcentre")
  ];

  sops.secrets."public_addr/thinkcentre" = { };
  sops.secrets."public_addr/adb_devs" = { };
  sops.secrets."public_addr/prisme_integration" = { };
  sops.secrets."public_addr/prisme_nightly" = { };

  sops.templates."ssh/hosts".content = ''
    Host thinkcentre-tunnel
      Port 2022
      User komar
      HostName ${p."public_addr/thinkcentre"}
      ServerAliveInterval 30
      ServerAliveCountMax 3
      RemoteForward [localhost]:9022 [localhost]:22
      ExitOnForwardFailure yes
      RemoteForward 9999

    Host ${p."public_addr/adb_devs"}
      User M.Trybus
      HostName ${p."public_addr/adb_devs"}

    Host integration
      Port 2222
      User adb-users
      HostName ${p."public_addr/prisme_integration"}
      ServerAliveInterval 5

    Host nightly
      Port 2222
      User adb-admins
      HostName ${p."public_addr/prisme_nightly"}
      ServerAliveInterval 5
  '';
}
