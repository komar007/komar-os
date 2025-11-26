{ ... }:
{
  programs.mpv.enable = true;
  programs.mpv.config = {
    hwdec = "auto-safe";
    profile = "fast";
  };
}
