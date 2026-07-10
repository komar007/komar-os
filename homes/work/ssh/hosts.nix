{ config, lib, ... }:
let
  p = config.sops.placeholder;
  secretMatchBlock = host: sopsAddressId: block: {
    sops.secrets."public_addr/${sopsAddressId}" = { };
    programs.ssh.settings.${host} = block p."public_addr/${sopsAddressId}";
  };
  prismeDeployment =
    name: address: User: Port:
    secretMatchBlock name "prisme/${address}" (HostName: {
      inherit HostName User Port;
      ServerAliveInterval = 5;
    });
  prismeDeployment1vm = name: user: prismeDeployment name name user 2222;
  prismeDeploymentSrv = name: user: prismeDeployment "${name}-services" name user 2222;
  prismeDeploymentDbs = name: user: prismeDeployment "${name}-db" name user 2223;
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
    (prismeDeployment1vm "integration" "adb-users")
    (prismeDeployment1vm "nightly" "adb-admins")
    (prismeDeployment1vm "perftest" "ubuntu")
    (prismeDeployment1vm "demo" "mtrybus")

    (prismeDeploymentSrv "optima-staging" "mtrybus")
    (prismeDeploymentDbs "optima-staging" "ubuntu")
  ]
