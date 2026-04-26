{
  config,
  lib,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  wait_for_x_prop = pkgs.rustPlatform.buildRustPackage {
    pname = "wait_for_x_prop";
    version = "0.1.0";
    src = ./wait_for_x_prop;
    cargoHash = "sha256-9hKbcTKM1Gn+UPYoryQ7jbq7Ij8nf/nXonw03B3/oY4=";
  };
in
{
  options.xmonad.config = {
    font = lib.mkOption {
      type = lib.types.str;
      default = "JetBrainsMono Nerd Font:pixelsize=16";
    };
    promptHeight = lib.mkOption {
      type = lib.types.int;
      default = 18;
    };
    tabsHeight = lib.mkOption {
      type = lib.types.int;
      default = 24;
    };
    hiRes = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    mainWsGroup = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ "c1" ];
    };
  };

  config.home.packages = with pkgs; [
    wiremix
    xsel
    dzen2
    xmobar
    xwallpaper
    xsecurelock
    xautolock
    fshf
    # TODO: temporarily in global scope, to be interpolated into xinitrc
    wait_for_x_prop
  ];

  config.xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;

    extraPackages = haskellPackages: [
      haskellPackages.aeson
    ];
  };

  config.home.file.".config/xmonad.json".text = builtins.toJSON (
    with config.xmonad.config;
    {
      inherit
        font
        promptHeight
        tabsHeight
        hiRes
        mainWsGroup
        ;
    }
  );

  config.home.file.".wallpaper.png".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/D3Ext/aesthetic-wallpapers/refs/heads/main/images/minimal_gradient.png";
    sha256 = "sha256:1rp0w67a7v3fivjlh3ima2agbis6r1gj822mfln6z5n056c415jn";
  };

  config.services.picom.enable = true;
  config.services.picom = {
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

  config.services.picom.package = pkgsUnstable.picom;
}
