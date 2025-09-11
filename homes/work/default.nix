{
  config,
  pkgs,
  nixpkgs-unstable,
  ...
}:
let
  utils = import ../modules/k3s/utils.nix { pkgs = nixpkgs-unstable; };
in
{
  imports = [
    ../modules/firefox
    ../modules/firefox/containers/home.nix
    ../modules/qutebrowser.nix
    ../modules/xmonad.nix
    ../modules/mpv.nix
    ../modules/vial
    ../modules/teams
    ../modules/jira.nix

    ../modules/sops

    ./ssh
  ];

  home.pointerCursor.size = 16;

  alacritty.font = "Terminess Nerd Font Mono";
  alacritty.font-italic = "ZedMono Nerd Font";
  alacritty.font-size = 9.0;
  alacritty.font-offset = -2;
  alacritty.glyph-offset = -1;
  programs.alacritty.settings = {
    window.padding = {
      x = 0;
      y = 0;
    };
  };

  dot-tmux.common-session-names = [
    "prisme-backend"
    "tss"
  ];
  dot-tmux.top.windows = [
    (utils.kubetui-with-namespace "prisme")
  ];

  # requires sops secrets definition in ./ssh/default.nix
  firefox-darkmode.exclude =
    let
      p = config.sops.placeholder;
    in
    [
      p."public_addr/prisme_integration"
      p."public_addr/prisme_nightly"
      "i.pl.adbglobal.com"
    ];

  # FIXME: generalize
  sops.templates."firefox/extensions/darkmode/settings".content =
    config.home.file.".mozilla/firefox/default/browser-extension-data/{174b2d58-b983-4501-ab4b-07e71203cb43}/storage.js".text;
  home.file.".mozilla/firefox/default/browser-extension-data/{174b2d58-b983-4501-ab4b-07e71203cb43}/storage.js".enable =
    false;

  home.file."___firefox/extensions/darkmode/settings" = {
    target = ".mozilla/firefox/default/browser-extension-data/{174b2d58-b983-4501-ab4b-07e71203cb43}/storage.js";
    source =
      config.lib.file.mkOutOfStoreSymlink
        config.sops.templates."firefox/extensions/darkmode/settings".path;
  };

  xdg.default-browser-app = "firefox.desktop";

  home.packages = with pkgs; [
    thunderbird

    uv
    temporal-cli
    mosquitto
    nixpkgs-unstable.codex

    nerd-fonts.zed-mono
  ];

  home.stateVersion = "24.11";
}
