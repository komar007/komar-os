{ lib, pkgs, ... }:
{
  imports = [
    ../common_desktop.nix

    ../modules/firefox/pinned-sites-home.nix
    ../modules/chromium.nix

    ./ssh
  ];

  home = {
    username = lib.mkForce "komar";
    homeDirectory = lib.mkForce "/home/komar";
  };

  home.pointerCursor.size = 32;

  chromium.enableVaapiAmdFeatures = true;

  alacritty.font = "JetBrainsMono Nerd Font";
  alacritty.fontSize = 7.0;

  home.packages = with pkgs; [
    exiftool
    signal-desktop
  ];

  home.stateVersion = "24.11";
}
