{ config, lib, ... }:
let
  p = config.sops.placeholder;
  secretMatchBlock = host: sopsAddressId: block: {
    sops.secrets."public_addr/${sopsAddressId}" = { };
    programs.ssh.settings.${host} = block p."public_addr/${sopsAddressId}";
  };
  prismeDeployment =
    name: User:
    secretMatchBlock name "prisme/${name}" (HostName: {
      inherit HostName User;
      Port = 2222;
      ServerAliveInterval = 5;
    });
in
builtins.foldl' lib.recursiveUpdate
  {
    programs.ssh.settings."devs.adbglobal.com" = {
      HostName = "devs.adbglobal.com";
      User = "M.Trybus";
    };
    programs.ssh.settings."prismetest" = {
      HostName = "10.60.1.233";
      User = "localadmin";
    };
  }
  [
    (secretMatchBlock "thinkcentre-tunnel" "thinkcentre" (HostName: {
      inherit HostName;
      Port = 2022;
      User = "komar";
      ServerAliveInterval = 30;
      ServerAliveCountMax = 3;
      RemoteForward = [
        "[localhost]:${toString (import ./matchblock.nix).Port} [localhost]:22"
        "9999"
      ];
      ExitOnForwardFailure = true;
    }))
    (prismeDeployment "integration" "adb-users")
    (prismeDeployment "nightly" "adb-admins")
    (prismeDeployment "perftest" "ubuntu")
  ]
