{ lib, pkgs, ... }:
{
  systemd.services.regulate-brightness = {
    description = "adjust screen brightness based on illuminance";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
    };
    script = lib.getExe (
      pkgs.writeShellApplication {
        name = "regulate-script";
        runtimeInputs = [ pkgs.bc ];
        text = builtins.readFile ./regulate-script.sh;
      }
    );
  };
}
