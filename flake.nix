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

    dot-nvim = {
      url = "github:komar007/dot-nvim";
      inputs.flake-utils.follows = "flake-utils";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.systems.follows = "systems";
    };
    dot-tmux = {
      url = "github:komar007/dot-tmux";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      nixpkgs-stable =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.nur.overlays.default
            inputs.nixgl.overlay
            inputs.rust-overlay.overlays.default
          ];
        };
      nixpkgs-unstable =
        system:
        import inputs.nixpkgs-unstable {
          inherit system;
        };
      nvim-module = system: inputs.dot-nvim.homeManagerModules.${system}.default;
      tmux-module = system: inputs.dot-tmux.homeManagerModules.${system}.default;
      tmux-alacritty-module = system: inputs.dot-tmux.homeManagerModules.${system}.alacrittyKeyBinds;
      grub-themes-module = system: inputs.grub-themes.nixosModules.default;
      sops-pkgs = system: inputs.sops-nix.packages.${system};

      nixosConfiguration =
        name: system:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs = {
            configuration-name = name;
            nixos-hardware = inputs.nixos-hardware;
            nixpkgs-unstable = nixpkgs-unstable system;
            grub-themes-module = grub-themes-module system;
            sops-pkgs = sops-pkgs system;
            sops-nix = inputs.sops-nix;
          };
          modules = [
            ./machines/common.nix
            ./machines/${name}
          ];
        };

      homeConfiguration =
        name: system:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs-stable system;
          extraSpecialArgs = {
            nixpkgs-unstable = nixpkgs-unstable system;
            nvim-module = nvim-module system;
            tmux-module = tmux-module system;
            tmux-alacritty-module = tmux-alacritty-module system;
            nixgl = inputs.nixgl;
          };
          modules = [
            ./homes/common.nix
            ./homes/${name}
          ];
        };
      eachSystem =
        f:
        inputs.nixpkgs.lib.genAttrs (import inputs.systems) (
          system: f inputs.nixpkgs.legacyPackages.${system}
        );
      treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
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
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
