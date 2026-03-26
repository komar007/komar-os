{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dot-tmux.top = {
    windows = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
    };
  };

  config.dot-tmux.common-session-names = [
    "top"
  ];

  config.dot-tmux.session-shells.top =
    let
      cases = lib.imap1 (i: command: "${toString i}) ${command} ;;") config.dot-tmux.top.windows;
    in
    pkgs.lib.getExe (
      pkgs.writeShellApplication {
        name = "top";
        text = ''
          case $(tmux display-message -pF '#{window_index}') in
          ${lib.concatStringsSep "\n" cases}
          *) "$SHELL" ;;
          esac
        '';
      }
    );
}
