{ config, lib, ... }:
{
  options.ssh = {
    authorizedKeys = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
    };
  };

  config.programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      serverAliveInterval = 100;
      serverAliveCountMax = 3;
    };
  };

  config.home.file.".ssh/authorized_keys" =
    let
      keys = map lib.strings.trim config.ssh.authorizedKeys;
    in
    lib.mkIf (lib.lists.length keys > 0) {
      text = lib.concatStringsSep "\n" keys + "\n";
    };
}
