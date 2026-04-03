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

  config.dot-tmux.commonSessionNames = [
    "top"
  ];

  config.dot-tmux.sessionShells.top =
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
