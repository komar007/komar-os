{ lib, pkgs, ... }: {
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "DMZ-Black";
    package = pkgs.vanilla-dmz;
  };

  home.packages = with pkgs; [
    xclip
    xorg.xset

    geeqie
    feh
    scrot
    imagemagick
    gnuplot
    xcolor
  ];
}
