{ lib, pkgs, config, ... }:
{
  home.file.".config/youtube-tui/main.yml".source =
  let
    mpv-ytdl = (pkgs.writeShellApplication {
      name = "mpv-ytdl";
      runtimeInputs = with pkgs; [ mpv yt-dlp ];
      text = ''
        mpv ytdl://"$1"
      '';
    });
  in (pkgs.formats.yaml {}).generate "main.yml" {
    env = {
      video-player = pkgs.lib.getExe mpv-ytdl;
    };
  };
}
