{
  lib,
  config,
  pkgs,
  pkgsUnstable,
  ...
}:
let
  utils = import ../modules/k3s/utils.nix { pkgs = pkgsUnstable; };
  ffUtils = import ../modules/firefox/utils.nix { inherit config lib; };
in
{
  imports = [
    ../common_desktop.nix

    ../modules/firefox/containers/home.nix
    ../modules/qutebrowser.nix
    ../modules/vial
    ../modules/teams

    ../modules/sops

    ./ssh
    ./jira
  ];

  home.pointerCursor.size = 16;

  xmonad.config = {
    font = "xft:Terminess Nerd Font Mono:pixelsize=12";
    promptHeight = 12;
    tabsHeight = 16;
    hiRes = false;
    mainWsGroup = [
      "mail"
      "c2"
      "c3"
    ];
  };

  quirks.gitBranchSymbol = "⎇ ";
  alacritty.font = "Terminess Nerd Font Mono";
  alacritty.fontItalic = "ZedMono Nerd Font";
  alacritty.fontSize = 9.0;
  alacritty.fontOffset = -2;
  alacritty.glyphOffset = -1;
  programs.alacritty.settings = {
    window.padding = {
      x = 0;
      y = 0;
    };
  };

  dot-tmux.commonSessionNames = [
    "prisme-backend"
    "tss"
  ];
  dot-tmux.top.windows = [
    (utils.kubetuiWithNamespace "prisme")
  ];

  sopsAnything.homeFiles = [
    (ffUtils.extensionSettingsFile pkgs.nur.repos.rycee.firefox-addons.dark-mode-webextension)
  ];
  sops.secrets."public_addr/prisme/integration" = { };
  sops.secrets."public_addr/prisme/nightly" = { };
  firefoxDarkmode.exclude =
    let
      p = config.sops.placeholder;
    in
    [
      p."public_addr/prisme/integration"
      p."public_addr/prisme/nightly"
      "i.pl.adbglobal.com"
    ];

  home.packages = with pkgs; [
    thunderbird

    uv
    temporal-cli
    mosquitto
    pkgsUnstable.codex
    pkgsUnstable.git-gr

    nerd-fonts.zed-mono
  ];

  home.stateVersion = "24.11";
}
