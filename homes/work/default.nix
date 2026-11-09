{
  lib,
  config,
  pkgs,
  ...
}:
let
  utils = import ../modules/k3s/utils.nix { inherit pkgs; };
  ffUtils = import ../modules/firefox/utils.nix { inherit config lib; };
in
{
  imports = [
    ../common_desktop.nix
    ../modules/thunderbird

    ../modules/firefox/containers/home.nix
    ../modules/firefox/pinned-sites-work.nix
    ../modules/qutebrowser.nix
    ../modules/vial
    ../modules/teams
    ../modules/codex

    ../modules/sops

    ./ssh
    ./jira
  ];

  home.pointerCursor.size = 16;

  xmonad.config = {
    font = "Terminess Nerd Font Mono:pixelsize=12";
    promptHeight = 12;
    tabsHeight = 12;
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
    "cdn"
    "deployment"
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
      "adbglobal.atlassian.net"
    ];

  programs.codex.settings =
    let
      repos = "${config.home.homeDirectory}/repos";
    in
    {
      projects."${repos}/unistack".trust_level = "trusted";
      projects."${repos}/prisme-backend".trust_level = "trusted";
      projects."${repos}/tools".trust_level = "trusted";
      projects."${repos}/tss".trust_level = "trusted";
      projects."${repos}/cdn".trust_level = "trusted";
    };

  home.packages = with pkgs; [
    uv
    temporal-cli
    mosquitto
    git-gr
    dive

    nerd-fonts.zed-mono
  ];

  home.stateVersion = "24.11";
}
