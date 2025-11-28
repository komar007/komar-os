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
  ];

  home.pointerCursor.size = 32;

  alacritty.font = "JetBrainsMono Nerd Font";
  alacritty.font-size = 9.0;

  chromium.enable-vaapi-intel-features = true;

  xdg.default-browser-app = "firefox.desktop";

  programs.ssh.matchBlocks.work-pc = {
    host = "work-vpn";
    hostname = "192.168.134.42";
    proxyJump = "adb-jumphost";
    port = 22;
    user = "komar";
    forwardX11 = true;
  };
  programs.ssh.matchBlocks.adb-jumphost = {
    host = "adb-jumphost";
    hostname = "192.168.5.68";
    port = 22;
    user = "M.Trybus";
  };
  programs.ssh.matchBlocks.work-pc-tunnel = {
    host = "work";
    hostname = "localhost";
    port = 9022;
    user = "komar";
    forwardX11 = true;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  home.packages = with pkgs; [
    super-slicer

    exiftool
    blender
    gimp
    unetbootin
    spotifyd

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
