{ pkgs, pkgsUnstable, ... }:
{
  imports = [
    ../common_desktop.nix

    ../modules/firefox/containers/work.nix
    ../modules/firefox/pinned-sites-home.nix
    ../modules/chromium.nix
    ../modules/vial

    ./ssh
  ];

  home.pointerCursor.size = 32;

  alacritty.font = "JetBrainsMono Nerd Font";
  alacritty.fontSize = 9.0;

  chromium.enableVaapiIntelFeatures = true;

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  home.packages = with pkgs; [
    pkgsUnstable.codex

    super-slicer-beta

    exiftool
    blender
    gimp
    unetbootin
    spotifyd
    signal-desktop

    dosbox
    wine
    jazz2
    calibre
    flashgbx
  ];

  home.stateVersion = "23.11";
}
