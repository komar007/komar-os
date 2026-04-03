# TODO: support multiple parallel connections
{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.maintainSshConnection = {
    host = lib.mkOption {
      type = lib.types.str;
    };
    user = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.systemd.services.maintain-ssh-connection = {
    description = "maintain ssh connection to a host";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      User = config.maintainSshConnection.user;
    };
    script =
      let
        script = lib.getExe (
          pkgs.writeShellApplication {
            name = "maintain-ssh-connection";
            runtimeInputs = [ pkgs.openssh ];
            text = builtins.readFile ./maintain-ssh-connection.sh;
          }
        );
      in
      "${script} ${config.maintainSshConnection.host}";
  };
}
