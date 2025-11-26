{ lib, pkgs, ... }:
{
  programs.git.enable = true;
  programs.git.aliases = {
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
    as = "!${pkgs.writeShellScript "git-as" ''
      if [ -n "$1" ]; then
        BASE="$1"
      else
        BASE=$(
          git log --format='%H' HEAD^ \
          | grep -m 1 --color=never -F $(git branch --format='-e %(objectname)')
        )
      fi
      if [ -z "$BASE" ]; then
        echo "CANNOT FIND BASE, specify manually" 2>/dev/stderr
        exit 1
      fi
      git rebase -i --autosquash "$BASE"
    ''}";
    newdate = "commit --amend --no-edit --date=now";
  };
  programs.git.includes = [
    { path = "~/.gitconfig.local"; }
  ];
  programs.git.extraConfig = {
    color = {
      ui = "auto";
    };
    core = {
      whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
      autocrlf = false;
      pager = "less -FRX";

    };
    http = {
      cookiefile = "~/.gitcookies";
    };
    push = {
      default = "matching";
    };
  };
}
