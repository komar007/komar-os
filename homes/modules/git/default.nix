{ lib, pkgs, ... }:
let
  delta = pkgs.lib.getExe pkgs.delta;
in
{
  programs.git.enable = true;
  programs.git.settings.alias = {
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
          text = builtins.readFile ./pg.sh;
        }
      )
    }";
    pick = "!${
      lib.getExe (
        pkgs.writeShellApplication {
          name = "git-pick";
          runtimeInputs = with pkgs; [
            fzf
          ];
          text = builtins.readFile ./pick.sh;
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
  programs.git.includes = [
    { path = "~/.gitconfig.local"; }
  ];
  programs.git.settings = {
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
      conflictStyle = "zdiff3";
    };
  };

  programs.git.settings.delta = {
    navigate = true;
    dark = true;
    grep-match-word-style = "#000000 #fabd2f";
  };
}
