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

  chromium.enable-vaapi-amd-features = true;

  xdg.default-browser-app = "firefox.desktop";

  alacritty.font = "JetBrainsMono Nerd Font";
  alacritty.font-size = 7.0;

  home.packages = with pkgs; [
    exiftool
  ];

  home.stateVersion = "24.11";
}
