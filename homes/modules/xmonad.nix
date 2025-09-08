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
      blur = {
        method = "dual_kawase";
        strength = 5;
      };
    };
  };
}
