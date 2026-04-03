{
  config,
  lib,
  pkgs,
  tmuxModule,
  tmuxAlacrittyModule,
  ...
}:
{
  options.dot-tmux = {
    sessionShells = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
    };
    commonSessionNames = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
    };
  };

  imports = [
    tmuxModule
    tmuxAlacrittyModule
  ];

  # TODO: perhaps generate .session_dir.sh in a similar way as .shell.sh
  config.home.file.".session_dir.sh".source = ./session_dir.sh;

  config.home.file.".shell.sh".source =
    let
      shells = config.dot-tmux.sessionShells;
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
      names = config.dot-tmux.commonSessionNames;
    in
    {
      enable = lib.lists.length names > 0;
      text = lib.strings.concatStringsSep "\n" names + "\n";
    };

  config.dot-tmux = {
    commonSessionNames = [
      "config"
    ];

    top.windows = [
      "btop"
    ];
  };
}
