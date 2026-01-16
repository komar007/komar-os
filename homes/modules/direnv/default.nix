{ direnv-instant, ... }:
{
  imports = [
    direnv-instant.homeModules.direnv-instant
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.config = {
    strict_env = true;
  };
  home.file.".config/direnv/direnvrc".source = ./direnvrc;

  programs.direnv-instant.enable = true;
  programs.direnv-instant.settings = {
    mux_delay = 1;
  };
}
