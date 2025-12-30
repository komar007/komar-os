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

  # This is a workaround, see https://github.com/nix-community/home-manager/issues/3090#issuecomment-3341948190.
  # openssh will not accept any permissions > 0600, which is what we get from HM.
  config.home.file.".ssh/authorized_keys_link" =
    let
      keys = map lib.strings.trim config.ssh.authorizedKeys;
    in
    lib.mkIf (lib.lists.length keys > 0) {
      text = lib.concatStringsSep "\n" keys + "\n";
      onChange = ''
        if [ -f ~/.ssh/authorized_keys ] && ! [ -f ~/.ssh/authorized_keys.old_no_hm ]; then
          mv ~/.ssh/authorized_keys ~/.ssh/authorized_keys.old_no_hm
        fi
        cat ~/.ssh/authorized_keys_link > ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
      '';
      force = true;
    };
}
