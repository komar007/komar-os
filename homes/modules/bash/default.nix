{ config, ... }:
{
  programs.bash.enable = true;
  programs.bash.bashrcExtra = builtins.readFile ./bashrc;
  programs.bash.initExtra = ''
    export __BASHRC_GIT_BRANCH_SYMBOL__="${config.quirks.gitBranchSymbol}"
  '';
}
