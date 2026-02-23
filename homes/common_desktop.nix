{ pkgs, ... }:
{
  imports = [
    ./modules/x11.nix
    ./modules/alacritty.nix
    ./modules/youtube-tui.nix
    ./modules/xmonad
    ./modules/mpv.nix
    ./modules/firefox
  ];

  # automatically regenerate fc-cache
  fonts.fontconfig.enable = true;

  xdg.defaultBrowserApp = "firefox.desktop";

  home.packages = with pkgs; [
    # Cascadia Code contains Symbols for Legacy Computing, required for example by dot-tmux ribbons.
    cascadia-code
    nerd-fonts.terminess-ttf
    nerd-fonts.jetbrains-mono
  ];
}
