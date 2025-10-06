{ lib, pkgs, nixpkgs-unstable, config, nixgl, ... }: {
  imports = [
    ../modules/firefox
    ../modules/firefox/containers/home.nix
    ../modules/qutebrowser.nix
    ../modules/xmonad.nix
    ../modules/mpv.nix
    ../modules/vial
  ];

  nixGL.packages = nixgl.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];
  nixGL.vulkan.enable = true;

  nixpkgs.overlays =
  let
    makeNixGlWrappedOverlay = pkgs:
      final: prev: builtins.listToAttrs (
        map (pkg: { name = pkg; value = config.lib.nixGL.wrap prev.${pkg}; }) pkgs
      );
  in
  [
    (makeNixGlWrappedOverlay [
      "alacritty"
      "mpv"
      "firefox"
      "qutebrowser"
      "geeqie"
    ])
  ];

  home.pointerCursor.size = 16;

  alacritty.font = "Terminess Nerd Font Mono";
  alacritty.font-italic = "ZedMono Nerd Font";
  alacritty.font-size = 9.0;
  alacritty.font-offset = -2;
  alacritty.glyph-offset = -1;
  programs.alacritty.settings = {
    font.builtin_box_drawing = false;
    window.padding = {
      x = 0;
      y = 0;
    };
  };

  xdg.default-browser-app = "firefox.desktop";

  home.packages = with pkgs; [
    geeqie
    feh
    scrot
    imagemagick
    gnuplot
    xcolor

    thunderbird

    uv
    temporal-cli

    kanata

    nerd-fonts.zed-mono

    xorg.xset
  ];

  home.stateVersion = "24.11";
}
