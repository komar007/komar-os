{ lib, pkgs, wiremix, ... }: {
  home.packages = with pkgs; [
    xmonad-with-packages
    wiremix.default
    xsel
    dzen2
    xmobar
    htop
    xwallpaper
  ];

  home.file.".wallpaper.png".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/refs/heads/main/images/minimal_gradient.png";
    sha256 = "sha256:1rp0w67a7v3fivjlh3ima2agbis6r1gj822mfln6z5n056c415jn";
  };

  imports = [
    ./session-chooser
  ];

  services.picom.enable = true;
  services.picom = {
    backend = "glx";
    settings = {
      vsync = true;
      fading = true;
      fade-in-step = 0.15;
      fade-out-step = 0.15;
      blur = {
        method = "dual_kawase";
        strength = 4;
      };
      blur-background-exclude = ''window_type *= "menu"'';
      shadow = true;
      # FIXME: exclude the windows firefox creates when dragging things
      shadow-exclude = ''_NET_WM_STRUT || window_type *= "menu"'';
      shadow-offset-x = -18;
      shadow-offset-y = -18;
      crop-shadow-to-monitor = true;
    };
  };
}
