{ lib, pkgs, wiremix, ... }: {
  home.packages = with pkgs; [
    xmonad-with-packages
    wiremix.default
    xsel
    dzen2
    xmobar
    htop
  ];

  services.picom.enable = true;
  services.picom = {
    backend = "glx";
    settings = {
      vsync = true;
      blur = {
        method = "dual_kawase";
        strength = 5;
      };
      blur-background-exclude = ''window_type *= "menu"'';
      shadow = true;
      shadow-exclude = ''_NET_WM_STRUT || window_type *= "menu"'';
      shadow-offset-x = -18;
      shadow-offset-y = -18;
      crop-shadow-to-monitor = true;
    };
  };
}
