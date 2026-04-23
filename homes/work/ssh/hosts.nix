{ config, lib, ... }:
let
  p = config.sops.placeholder;
  secretMatchBlock = sopsAddressId: block: {
    sops.secrets."public_addr/${sopsAddressId}" = { };
    programs.ssh.matchBlocks.${"__smb__" + sopsAddressId} = block p."public_addr/${sopsAddressId}";
  };
  prismeDeployment =
    name: user:
    secretMatchBlock "prisme/${name}" (hostname: {
      host = name;
      inherit hostname user;
      port = 2222;
      serverAliveInterval = 5;
    });
in
builtins.foldl' lib.recursiveUpdate { } [
  (secretMatchBlock "thinkcentre" (hostname: {
    host = "thinkcentre-tunnel";
    inherit hostname;
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
  }))
  (secretMatchBlock "adb_devs" (hostname: {
    host = hostname;
    inherit hostname;
    user = "M.Trybus";
  }))
  (prismeDeployment "integration" "adb-users")
  (prismeDeployment "nightly" "adb-admins")
  (prismeDeployment "perftest" "ubuntu")
]
