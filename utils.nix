inputs:
let
  lib = inputs.nixpkgs.lib;

  pkgsStable =
    system:
    import inputs.nixpkgs {
      inherit system;
      overlays = import ./stable-overlays.nix inputs;
    };
  pkgsUnstable =
    system:
    import inputs.nixpkgs-unstable {
      inherit system;
    };

  nixosConfiguration =
    name: system:
    lib.nixosSystem {
      specialArgs = {
        configurationName = name;
        inherit inputs;
        grubThemesModule = inputs.grub-themes.nixosModules.default;
        pkgsUnstable = pkgsUnstable system;
      };
      modules = [
        ./machines/common.nix
        ./machines/${name}
      ];
    };

  homeConfiguration =
    let
      # Sane pure defaults for options that require impure evaluation in ./homes/common.nix.
      # They are only added in "flake check" mode to enable flake-checking of configurations
      # that purposely rely on impure evaluation to be independent of username and $HOME.
      purityOverridesModule =
        { lib, ... }:
        {
          home.username = lib.mkDefault "username";
          home.homeDirectory = lib.mkDefault "/dev/null";
        };
    in
    isCheck: name: system: nixosUserConfig:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsStable system;
      extraSpecialArgs = {
        configurationName = name;
        inherit inputs nixosUserConfig;
        nixIndexDatabaseModule = inputs.nix-index-database.homeModules.default;
        pkgsUnstable = pkgsUnstable system;
        nvimModule = inputs.dot-nvim.homeManagerModules.${system}.default;
        tmuxModule = inputs.dot-tmux.homeManagerModules.${system}.default;
        tmuxAlacrittyModule = inputs.dot-tmux.homeManagerModules.${system}.alacrittyKeyBinds;
      };
      modules = [
        ./homes/common.nix
        ./homes/${name}
      ]
      ++ lib.optional isCheck purityOverridesModule;
    };
in
{
  inherit nixosConfiguration homeConfiguration;
  eachSystem =
    f: lib.genAttrs (import inputs.systems) (system: f system inputs.nixpkgs.legacyPackages.${system});
  filterSystem =
    system: lib.filterAttrs (_: config: config.pkgs.stdenv.hostPlatform.system == system);
}
