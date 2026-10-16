{ config, lib, ... }:
let
  p = config.sops.placeholder;
  secretMatchBlock = host: sopsAddressId: block: {
    sops.secrets."public_addr/${sopsAddressId}" = { };
    programs.ssh.settings.${host} = block p."public_addr/${sopsAddressId}";
  };

  # PRISME 1.0 project @ ADB
  # Deployments are on public addresses stored in sops
  prismeDeployment =
    name: address: User: Port:
    secretMatchBlock name "prisme/${address}" (HostName: {
      inherit HostName User Port;
      ServerAliveInterval = 5;
    });
  prismeDeployment1vm = name: user: prismeDeployment name name user 2222;
  prismeDeploymentSrv = name: user: prismeDeployment "${name}-services" name user 2222;
  prismeDeploymentDbs = name: user: prismeDeployment "${name}-db" name user 2223;

  # CDN Cache project @ ADB
  # Deployments are in the office network, private IP pool addresses are in plain-text
  cdnDeployment = name: address: {
    programs.ssh.settings.${name} = {
      HostName = address;
      User = "katowice";
      ServerAliveInterval = 5;
    };
  };
  # Vm deployments forward some specific ports to the host machine
  cdnVm = name: port: {
    programs.ssh.settings.${name} = {
      HostName = "localhost";
      Port = port;
      User = "katowice";
      ServerAliveInterval = 5;
    };
  };
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

    (prismeDeployment1vm "integration" "mtrybus")
    (prismeDeployment1vm "nightly" "mtrybus")
    (prismeDeployment1vm "nightly-old" "adb-admins")
    (prismeDeployment1vm "perftest" "ubuntu")
    (prismeDeployment1vm "demo" "mtrybus")

    (prismeDeploymentSrv "optima-staging" "mtrybus")
    (prismeDeploymentDbs "optima-staging" "ubuntu")

    (cdnDeployment "cdn-caching-client" "192.168.136.53")
    (cdnDeployment "cdn-caching-proxy" "192.168.136.52")
    (cdnDeployment "cdn-caching-cdn" "192.168.136.87")

    (cdnVm "vm-cdn-caching-client" 2224)
    (cdnVm "vm-cdn-caching-proxy" 2223)
    (cdnVm "vm-cdn-caching-cdn" 2222)
  ]
