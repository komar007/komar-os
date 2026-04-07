{
  description = "komar NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    systems.url = "github:nix-systems/default-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    grub-themes = {
      url = "github:vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    fshf = {
      url = "github:komar007/fshf";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dot-nvim = {
      url = "github:komar007/dot-nvim";
      inputs.flake-utils.follows = "flake-utils";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.systems.follows = "systems";
    };
    dot-tmux = {
      url = "github:komar007/dot-tmux";
      inputs.flake-utils.follows = "flake-utils";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.nixpkgs-nixfmt.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      lib = inputs.nixpkgs.lib;
      pkgsStable =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.nur.overlays.default
            inputs.nixgl.overlay
            inputs.rust-overlay.overlays.default
            inputs.fshf.overlays.default
          ];
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
        name: system:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsStable system;
          extraSpecialArgs = {
            configurationName = name;
            inherit inputs;
            nixIndexDatabaseModule = inputs.nix-index-database.homeModules.default;
            pkgsUnstable = pkgsUnstable system;
            nvimModule = inputs.dot-nvim.homeManagerModules.${system}.default;
            tmuxModule = inputs.dot-tmux.homeManagerModules.${system}.default;
            tmuxAlacrittyModule = inputs.dot-tmux.homeManagerModules.${system}.alacrittyKeyBinds;
          };
          modules = [
            ./homes/common.nix
            ./homes/${name}
          ];
        };

      nixosConfigurations = {
        thinkcentre = nixosConfiguration "thinkcentre" "x86_64-linux";
        framework = nixosConfiguration "framework" "x86_64-linux";
        work = nixosConfiguration "work" "x86_64-linux";
      };

      homeConfigurations = {
        thinkcentre = homeConfiguration "thinkcentre" "x86_64-linux";
        framework = homeConfiguration "framework" "x86_64-linux";
        work = homeConfiguration "work" "x86_64-linux";
      };

      eachSystem =
        f: lib.genAttrs (import inputs.systems) (system: f system inputs.nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (_: pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
      filterSystem =
        system: lib.filterAttrs (_: config: config.pkgs.stdenv.hostPlatform.system == system);
      homeManagerBuildChecks =
        system:
        lib.mapAttrs' (name: config: lib.nameValuePair "home-manager-${name}" config.activationPackage) (
          filterSystem system homeConfigurations
        );
      nixosBuildChecks =
        system:
        lib.mapAttrs' (
          name: config: lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel
        ) (filterSystem system nixosConfigurations);
    in
    {
      inherit nixosConfigurations homeConfigurations;

      formatter = eachSystem (system: _: treefmtEval.${system}.config.build.wrapper);
      checks = eachSystem (
        system: pkgs:
        {
          formatting = treefmtEval.${system}.config.build.check self;
          typos = pkgs.runCommand "typos-check" {
            nativeBuildInputs = [ pkgs.typos ];
          } "cd ${self} && typos . && touch $out";
        }
        // homeManagerBuildChecks system
        // nixosBuildChecks system
      );
    };
}
