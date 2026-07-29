{ pkgs, ... }:
let
  clip = pkgs.writeShellApplication {
    name = "clip";
    runtimeInputs = with pkgs; [
      mktemp
      xclip
      file
      coreutils
      jq
    ];
    text = ''
      if [ "$#" -gt 0 ]; then
        for filename in "$@"; do
          path=$(realpath -- "$filename")
          printf '%s' "$path" | jq -jR '"file://" + (@uri | gsub("%2[Ff]"; "/")) + "\r\n"'
        done | xclip -selection clipboard -t text/uri-list -i
        exit 0
      fi

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
    runtimeInputs = with pkgs; [
      xclip
      ncurses
    ];
    text = builtins.readFile ./unclip.sh;
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
      xset

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
