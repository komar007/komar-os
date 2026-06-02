{
  lib,
  pkgs,
  nixosUserConfig,
  inputs,
  ...
}:
let
  userAttr =
    confAttr: envName:
    let
      envVal = builtins.getEnv envName;
    in
    if nixosUserConfig != null then
      # if there is a related nixos user config, force it, don't allow overrides...
      lib.mkForce nixosUserConfig.${confAttr}
    else
      # ... otherwise, if no env, use default (used in flake check), but if env exists, it can still
      # be overridden using lib.mkForce
      lib.mkIf (envVal != "") envVal;
in
{
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = with inputs; [
    nur.overlays.default
    nixgl.overlay
    rust-overlay.overlays.default
    fshf.overlays.default
  ];

  home = {
    username = userAttr "name" "USER";
    homeDirectory = userAttr "home" "HOME";
  };

  imports = [
    ./modules/quirks.nix
    ./modules/bash
    ./modules/xdg.nix
    ./modules/dot-nvim.nix
    ./modules/tmux
    ./modules/tmux/top-session.nix
    ./modules/direnv
    ./modules/starship
    ./modules/git
    ./modules/tig
    ./modules/ssh
    ./modules/lsd.nix
    ./modules/rust.nix
    ./modules/comma.nix
  ];

  dot-tmux.sessionShells =
    let
      bc = pkgs.lib.getExe pkgs.bc;
    in
    {
      bc = "${bc} -l";
    };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    jq
    yq
    fzf
    bat

    unzip

    gnumake
    cmake
    gcc

    btop
    htop

    timg
  ];
}
