{ pkgs, pkgsUnstable, ... }:
let
  yank = pkgs.writeShellApplication {
    name = "yank";
    runtimeInputs = with pkgs; [
      tmux
      xsel
    ];
    text = ''tmux set-buffer "$1" && xsel --primary -i <<< "$1"'';
  };
  showJiraIssue = pkgs.writeShellApplication {
    name = "show-jira-issue";
    runtimeInputs = with pkgs; [ jira-cli-go ];
    text = ''
      SUBJECT=$(git show -s --format=%s "$1")
      ISSUE=$(sed -r 's/^(Revert(\^[0-9]+)? ")?\[[BIOF]\] *\[?([A-Z]+-[0-9]+).*/\3/' <<< "$SUBJECT")
      jira issue view --comments 100 "$ISSUE"
    '';
  };
  showGerritChange = pkgs.writeShellApplication {
    name = "show-gerrit-change";
    runtimeInputs = with pkgsUnstable; [ git-gr ];
    text = ''
      CHID=$(git show -s --format=%B "$1" | git interpret-trailers --parse | sed -n 's/^Change-Id: //p')
      git gr view "$CHID"
    '';
  };
  mainDiffBinds = [
    "R ?git revert %(commit)"
    "P ?git pg %(commit)"
    "F ?git commit --fixup %(commit)"
    "Y @${pkgs.lib.getExe yank} %(commit)"
    "J >${pkgs.lib.getExe showJiraIssue} %(commit)"
    "G >${pkgs.lib.getExe showGerritChange} %(commit)"
  ];
in
{
  imports = [
    ./gruvbox.nix
  ];

  home.packages = with pkgs; [
    tig
  ];

  tig-gruvbox.extra = [
    "default 246 default"
    "cursor-blur 223 236"
    "directory 4 default bold"
  ];

  programs.git.settings.tig = {
    "mouse" = true;

    "show-untracked" = false;
    "vertical-split" = false;

    "main-view-date" = "custom";
    "main-view-date-format" = "%Y-%m-%d";
    "main-view" = "date:relative author:full commit-title:graph=true,refs=true";
    "diff-view" = "line-number:display=false text:commit-title-overflow=true";
    "git-colors" = false;
    "truncation-delimiter" = "~";

    "commit-order" = "author-date";
  };

  programs.git.settings."tig \"bind\"" = {
    main = mainDiffBinds;
    diff = mainDiffBinds;
    generic = [
      "<Ctrl-f> move-page-down"
      "<Ctrl-b> move-page-up"
    ];
  };
}
