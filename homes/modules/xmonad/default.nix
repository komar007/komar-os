{
  config,
  lib,
  pkgs,
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
      default = 20;
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

  config.home.file.".wallpaper.png".source = ./anshul-cT0ol6ogBeM-unsplash.jpg;

  config.services.picom.enable = true;
  config.services.picom = {
    backend = "glx";
    settings = {
      unredir-if-possible = false;
      unredir-if-possible-exclude = [ "class_g = 'xsecurelock'" ];
      vsync = true;
      fading = true;
      fade-in-step = 0.15;
      fade-out-step = 0.15;
      blur = {
        method = "dual_kawase";
        strength = 6;
      };
      blur-background-exclude = ''window_type *= "menu" || role = "Popup"'';
      shadow = true;
      # FIXME: exclude the windows firefox creates when dragging things
      shadow-exclude = ''_NET_WM_STRUT || window_type *= "menu" || role = "Popup"'';
      shadow-offset-x = -18;
      shadow-offset-y = -18;
      crop-shadow-to-monitor = true;
      opacity-rule = [
        "85:window_type = 'dialog'"
        "20:class_g = 'xsecurelock'"
      ];
    };
  };

  config.xdg.configFile."picom/picom.conf".onChange = ''
    ${pkgs.procps}/bin/pkill -USR1 -u "$UID" -x picom || true
  '';

  config.services.picom.package = pkgs.picom;
}
