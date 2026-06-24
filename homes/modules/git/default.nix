{
  config,
  lib,
  pkgs,
  ...
}:
let
  delta = pkgs.lib.getExe pkgs.delta;
  gitAliasLib = pkgs.writeText "git-alias-lib.sh" (builtins.readFile ./lib.sh);
in
{
  options.git = {
    gitPickPattern = lib.mkOption {
      type = lib.types.str;
      default = ''^[a-z][a-z0-9-]*(\([^)]+\))?(!)?: .+''; # conventional commits
    };
  };

  config.programs.git.enable = true;
  config.programs.git.settings.alias = {
    uncommit = "!git reset --soft HEAD^ && git reset";
    wip = "commit -a -m wip";
    unwip = "!${pkgs.writeShellScript "git-unwip" ''
      if [ "$(git log -1 --pretty=format:%B | head -n 1)" = wip ]; then
        git uncommit
      else
        echo NOT A WIP 2>/dev/stderr
        exit 1
      fi
    ''}";
    pg = "!${
      lib.getExe (
        pkgs.writeShellApplication {
          name = "git-pg";
          runtimeInputs = with pkgs; [
            cowsay
            lolcat
          ];
          text = ''
            export GIT_ALIAS_LIB=${gitAliasLib}
          ''
          + builtins.readFile ./pg.sh;
        }
      )
    }";
    pick = "!${
      lib.getExe (
        pkgs.writeShellApplication {
          name = "git-pick";
          runtimeInputs = with pkgs; [
            fzf
            cowsay
            lolcat
          ];
          text = ''
            export GIT_PICK_COMMITMSG_PATTERN="''${GIT_PICK_COMMITMSG_PATTERN:-${config.git.gitPickPattern}}"
            export GIT_ALIAS_LIB=${gitAliasLib}
          ''
          + builtins.readFile ./pick.sh;
        }
      )
    }";
    as = "!${
      lib.getExe (
        pkgs.writeShellApplication {
          name = "git-as";
          text = builtins.readFile ./as.sh;
        }
      )
    }";
    newdate = "commit --amend --no-edit --date=now";
  };
  config.programs.git.includes = [
    { path = "~/.gitconfig.local"; }
  ];
  config.programs.git.settings = {
    color = {
      ui = "auto";
    };
    core = {
      whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
      autocrlf = false;
      pager = delta;
    };
    interactive = {
      diffFilter = "${delta} --color-only";
    };
    http = {
      cookiefile = "~/.gitcookies";
    };
    push = {
      default = "matching";
    };
    merge = {
      renamelimit = 10000;
      conflictStyle = "zdiff3";
    };
    diff = {
      renamelimit = 10000;
    };
  };

  config.programs.git.settings.delta = {
    navigate = true;
    dark = true;
    grep-match-word-style = "#000000 #fabd2f";
  };
}
