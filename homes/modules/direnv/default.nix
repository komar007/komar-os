{ inputs, pkgs, ... }:
{
  imports = [
    inputs.direnv-instant.homeModules.direnv-instant
    ./direnv-instant-wrapped.nix
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.direnv.config = {
    strict_env = true;
  };
  home.file.".config/direnv/direnvrc".source = ./direnvrc;

  programs.direnv-instant.enable = true;
  programs.direnv-instant.package = pkgs.direnv-instant-wrapped;
  programs.direnv-instant.settings = {
    mux_delay = 1;
  };

  direnv-instant-wrapped.bashHookPostlude =
    let
      ansifilter = pkgs.lib.getExe pkgs.ansifilter;
    in
    ''
      eval "_original_direnv_handler() $(declare -f _direnv_handler | tail -n +2)"
      _direnv_handler() {
        _original_direnv_handler | while read -r line; do
          tput setaf 2
          echo -n '󰌪 '
          tput setaf 8
          ${ansifilter} <<< "$line" | sed -r 's/^direnv: //'
          tput sgr0
        done
      }
    '';
}
