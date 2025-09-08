{
  description = "komar NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    systems.url = "github:nix-systems/default-linux";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wiremix = {
      url = "github:tsowell/wiremix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dot-nvim = {
      url = "github:komar007/dot-nvim";
      inputs.flake-utils.follows = "flake-utils";
    };
    dot-tmux = {
      url = "github:komar007/dot-tmux";
      inputs.flake-utils.follows = "flake-utils";
    };
    grub-themes = {
      url = "github:vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      nixpkgs-stable = system: import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.nur.overlays.default
          inputs.nixgl.overlay
        ];
      };
      nixpkgs-unstable = system: import inputs.nixpkgs-unstable {
        inherit system;
      };
      nvim-module = system: inputs.dot-nvim.homeManagerModules.${system}.default;
      tmux-module = system: inputs.dot-tmux.homeManagerModules.${system}.default;
      tmux-alacritty-module = system: inputs.dot-tmux.homeManagerModules.${system}.alacrittyKeyBinds;
      grub-themes-module = system: inputs.grub-themes.nixosModules.default;
      wiremix = system: inputs.wiremix.packages.${system};

      nixosConfiguration = name: system: nixpkgs.lib.nixosSystem {
        specialArgs = {
          nixos-hardware = inputs.nixos-hardware;
          nixpkgs-unstable = nixpkgs-unstable system;
          grub-themes-module = grub-themes-module system;
        };
        modules = [
          ./machines/common.nix
          ./machines/${name}
        ];
      };

      homeConfiguration = name: system: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs-stable system;
        extraSpecialArgs = {
          nixpkgs-unstable = nixpkgs-unstable system;
          wiremix = wiremix system;
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
    };
}
