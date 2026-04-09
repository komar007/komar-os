{
  pkgs,
  nvimModule,
  nixIndexDatabaseModule,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "komar";
    homeDirectory = "/home/komar";
  };

  imports = [
    ./modules/bash
    ./modules/xdg.nix
    nvimModule
    ./modules/tmux
    ./modules/tmux/top-session.nix
    ./modules/direnv
    ./modules/starship
    ./modules/git
    ./modules/tig
    ./modules/ssh
    ./modules/lsd.nix
    ./modules/rust.nix
    nixIndexDatabaseModule
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
  ];

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enableBashIntegration = false;
}
