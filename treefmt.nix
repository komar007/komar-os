{ pkgs, ... }:
let
  pandoc-markdown = pkgs.writeShellApplication {
    name = "pandoc-markdown";
    runtimeInputs = [ pkgs.pandoc ];
    text = ''
      for file in "$@"; do
        tmp=$(mktemp)
        pandoc -f gfm -t gfm --columns 100 "$file" -o "$tmp"
        mv "$tmp" "$file"
      done
    '';
  };
in
{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  settings.formatter.nixfmt.excludes = [ "machines/*/hardware-configuration.nix" ];

  settings.formatter.pandoc-markdown = {
    command = pandoc-markdown;
    includes = [ "*.md" ];
  };

  programs.shfmt.enable = true;
  programs.shfmt.useEditorConfig = true;
}
