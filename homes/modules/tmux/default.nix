{
  config,
  lib,
  pkgs,
  tmux-module,
  tmux-alacritty-module,
  ...
}:
{
  options.dot-tmux = {
    session-shells = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
    };
    common-session-names = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
    };
  };

  imports = [
    tmux-module
    tmux-alacritty-module
  ];

  # TODO: perhaps generate .session_dir.sh in a similar way as .shell.sh
  config.home.file.".session_dir.sh".source = ./session_dir.sh;

  config.home.file.".shell.sh".source =
    let
      shells = config.dot-tmux.session-shells;
      cases = lib.attrsets.mapAttrsToList (ses: sh: "${ses}) exec ${sh};;") shells;
      shell =
        "case \"$1\" in\n"
        + (builtins.concatStringsSep "" (builtins.map (c: "\t${c}\n") cases))
        + "\t*) exec \"$SHELL\";;\n"
        + "esac";
    in
    lib.getExe (pkgs.writeShellScriptBin "shell.sh" shell);

  config.home.file.".tmux_common_session_names" =
    let
      names = config.dot-tmux.common-session-names;
    in
    {
      enable = lib.lists.length names > 0;
      text = lib.strings.concatStringsSep "\n" names + "\n";
    };

  config.dot-tmux.common-session-names = [
    "config"
  ];
}
