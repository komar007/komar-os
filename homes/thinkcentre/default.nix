{ pkgs, ... }:
{
  imports = [
    ../modules/firefox
    ../modules/firefox/containers/work.nix
    ../modules/firefox/pinned-sites-home.nix
    ../modules/chromium.nix
    ../modules/xmonad.nix
    ../modules/mpv.nix
    ../modules/vial

    ./ssh
  ];

  home.pointerCursor.size = 32;

  alacritty.font = "JetBrainsMono Nerd Font";
  alacritty.font-size = 9.0;

  chromium.enable-vaapi-intel-features = true;

  xdg.default-browser-app = "firefox.desktop";

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  home.packages = with pkgs; [
    super-slicer

    exiftool
    blender
    gimp
    unetbootin
    spotifyd
    signal-desktop

    dosbox
    wine
    (jazz2.overrideAttrs (
      finalAttrs: previousAttrs: {
        version = "3.0.0";
        src = fetchFromGitHub {
          owner = "deathkiller";
          repo = "jazz2-native";
          rev = finalAttrs.version;
          hash = "sha256-t1bXREL/WWnYnSfCyAY5tus/Bq5V4HVHg9s7oltGoIg=";
        };
      }
    ))
    calibre
  ];

  home.stateVersion = "23.11";
}
