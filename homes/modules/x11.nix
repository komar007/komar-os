{ pkgs, ... }:
let
  clip = pkgs.writeShellApplication {
    name = "clip";
    runtimeInputs = with pkgs; [
      mktemp
      xclip
      file
    ];
    text = ''
      T=$(mktemp)
      cleanup() { rm "$T"; }
      trap cleanup EXIT
      cat > "$T"
      mime=$(file -b --mime-type "$T")
      xclip -selection clipboard -t "$mime" -i "$T"
    '';
  };
  unclip = pkgs.writeShellApplication {
    name = "unclip";
    runtimeInputs = [ pkgs.xclip ];
    text = ''
      xclip -selection clipboard -o -
    '';
  };
  sc = pkgs.writeShellApplication {
    name = "sc";
    runtimeInputs = [
      clip
      pkgs.scrot
    ];
    text = ''
      scrot -s -F- -d b1 | clip
    '';
  };
in
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "DMZ-Black";
    package = pkgs.vanilla-dmz;
  };

  home.packages =
    (with pkgs; [
      xclip
      xorg.xset

      geeqie
      feh
      scrot
      imagemagick
      gnuplot
      xcolor
    ])
    ++ [
      clip
      unclip
      sc
    ];
}
