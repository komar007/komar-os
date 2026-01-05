{ direnv-instant, ... }:
{
  imports = [
    direnv-instant.homeModules.direnv-instant
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.direnv-instant.enable = true;
  programs.direnv-instant.settings = {
    mux_delay = 1;
  };
}
