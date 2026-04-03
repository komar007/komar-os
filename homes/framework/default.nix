{ pkgs, ... }:
{
  imports = [
    ../modules/firefox
    ../modules/firefox/pinned-sites-home.nix
    ../modules/chromium.nix
    ../modules/xmonad.nix
    ../modules/mpv.nix

    ./ssh
  ];

  home.pointerCursor.size = 32;

  chromium.enableVaapiAmdFeatures = true;

  xdg.defaultBrowserApp = "firefox.desktop";

  alacritty.font = "JetBrainsMono Nerd Font";
  alacritty.fontSize = 7.0;

  home.packages = with pkgs; [
    exiftool
    signal-desktop
  ];

  home.stateVersion = "24.11";
}
