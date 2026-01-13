{ pkgs, ... }:
{
  home.packages = with pkgs; [
    xmonad-with-packages
    wiremix
    xsel
    dzen2
    xmobar
    xwallpaper
    xsecurelock
    xautolock
    fshf
  ];

  home.file.".wallpaper.png".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/refs/heads/main/images/minimal_gradient.png";
    sha256 = "sha256:1rp0w67a7v3fivjlh3ima2agbis6r1gj822mfln6z5n056c415jn";
  };

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

  # picom v12.5 sometimes crashes on amdgpu, the version below from master has been more stable so far...
  services.picom.package = pkgs.picom.overrideAttrs (old: {
    version = "v12";
    src = pkgs.fetchFromGitHub {
      owner = "yshui";
      repo = "picom";
      rev = "90e537110aa7125ad97aa781fdf956c93fa12436";
      hash = "sha256-lfusMFzfQwk97a4gyJwxQEuMlo1rWgoQR4H1wgyx7Bg=";
      fetchSubmodules = true;
    };
  });
}
