{ pkgs, nixpkgs-unstable, ... }:
let
  utils = import ../modules/k3s/utils.nix { pkgs = nixpkgs-unstable; };
in
{
  imports = [
    ../modules/firefox
    ../modules/firefox/containers/home.nix
    ../modules/qutebrowser.nix
    ../modules/xmonad.nix
    ../modules/mpv.nix
    ../modules/vial
    ../modules/teams
    ../modules/jira.nix

    ../modules/sops

    ./ssh
  ];

  home.pointerCursor.size = 16;

  alacritty.font = "Terminess Nerd Font Mono";
  alacritty.font-italic = "ZedMono Nerd Font";
  alacritty.font-size = 9.0;
  alacritty.font-offset = -2;
  alacritty.glyph-offset = -1;
  programs.alacritty.settings = {
    window.padding = {
      x = 0;
      y = 0;
    };
  };

  dot-tmux.common-session-names = [
    "prisme-backend"
    "tss"
  ];
  dot-tmux.top.windows = [
    (utils.kubetui-with-namespace "prisme")
  ];

  xdg.default-browser-app = "firefox.desktop";

  home.packages = with pkgs; [
    thunderbird

    uv
    temporal-cli
    mosquitto
    nixpkgs-unstable.codex

    nerd-fonts.zed-mono
  ];

  home.stateVersion = "24.11";
}
