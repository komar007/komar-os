{ config, ... }:
let
  p = config.sops.placeholder;
in
{
  sops.secrets."public_addr/adb_devs" = { };
  sops.secrets."public_addr/prisme_integration" = { };
  sops.secrets."public_addr/prisme_nightly" = { };

  sops.templates."ssh/hosts".content = ''
    Host ${p."public_addr/adb_devs"}
      User M.Trybus
      HostName ${p."public_addr/adb_devs"}

    Host integration
      Port 2222
      User adb-admins
      HostName ${p."public_addr/prisme_integration"}
      ServerAliveInterval 5

    Host nightly
      Port 2222
      User adb-admins
      HostName ${p."public_addr/prisme_nightly"}
      ServerAliveInterval 5
  '';
}
