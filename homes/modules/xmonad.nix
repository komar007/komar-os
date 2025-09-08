{ lib, pkgs, wiremix, ... }: {
  home.packages = with pkgs; [
    xmonad-with-packages
    wiremix.default
    xsel
    dzen2
    xmobar
    htop
  ];
}
