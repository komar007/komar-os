{ pkgs, nixpkgs-unstable, ... }:
{
  home.packages = [ nixpkgs-unstable.youtube-tui ];
  home.file.".config/youtube-tui/main.yml".source =
    let
      mpv-ytdl = pkgs.writeShellApplication {
        name = "mpv-ytdl";
        runtimeInputs = [ pkgs.mpv ];
        text = ''
          mpv ytdl://"$1"
        '';
      };
    in
    (pkgs.formats.yaml { }).generate "main.yml" {
      env = {
        video-player = pkgs.lib.getExe mpv-ytdl;
      };
    };
}
