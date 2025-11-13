{ lib, pkgs, nvim-module, nixpkgs-unstable, ... }: {
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "komar";
    homeDirectory = "/home/komar";
  };

  imports = [
    ./modules/x11.nix
    ./modules/xdg.nix
    nvim-module
    ./modules/tmux
    ./modules/alacritty.nix
    ./modules/starship
    ./modules/git
    ./modules/tig
    ./modules/ssh.nix
    ./modules/lsd.nix
    ./modules/rust.nix
    ./modules/youtube-tui.nix
  ];

  dot-tmux.session-shells = let
    bc = pkgs.lib.getExe pkgs.bc;
  in
  {
    btop = "btop";
    bc = "${bc} -l";
  };

  programs.home-manager.enable = true;

  # automatically regenerate fc-cache
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    jq
    yq
    fzf
    bat

    unzip

    gnumake
    cmake
    gcc
    bacon

    btop
    htop

    # Cascadia Code contains Symbols for Legacy Computing, required for example by dot-tmux ribbons.
    cascadia-code
    nerd-fonts.terminess-ttf
    nerd-fonts.jetbrains-mono
  ];
}
