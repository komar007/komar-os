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
    comma = {
      url = "github:nix-community/comma";
      inputs.utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dot-nvim = {
      url = "github:komar007/dot-nvim";
      inputs.flake-utils.follows = "flake-utils";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.systems.follows = "systems";
      inputs.home-manager.follows = "home-manager";
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
      utils = import ./utils.nix inputs;

      nixosConfigurations =
        let
          nixos = utils.nixosConfiguration;
        in
        {
          thinkcentre = nixos "thinkcentre" "x86_64-linux";
          framework = nixos "framework" "x86_64-linux";
          work = nixos "work" "x86_64-linux";
        };

      homeConfigurations =
        isCheck:
        let
          home = utils.homeConfiguration isCheck;
          nixosUsersFor = cfg: self.nixosConfigurations.${cfg}.config.users.users;
          komarAt = cfg: (nixosUsersFor cfg).komar;
        in
        {
          thinkcentre = home "thinkcentre" "x86_64-linux" (komarAt "thinkcentre");
          framework = home "framework" "x86_64-linux" (komarAt "framework");
          work = home "work" "x86_64-linux" (komarAt "work");
          minimal = home "minimal" "x86_64-linux" null;
        };

      homeManagerBuildChecks =
        system:
        lib.mapAttrs' (name: config: lib.nameValuePair "home-manager-${name}" config.activationPackage) (
          utils.filterSystem system (homeConfigurations true)
        );
      nixosBuildChecks =
        system:
        lib.mapAttrs' (
          name: config: lib.nameValuePair "nixos-${name}" config.config.system.build.toplevel
        ) (utils.filterSystem system nixosConfigurations);

      treefmtEval = utils.eachSystem (_: pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      inherit nixosConfigurations;
      homeConfigurations = homeConfigurations false;

      devShells = utils.eachSystem (
        _: pkgs: {
          default = pkgs.mkShell {
            buildInputs = [
              (pkgs.haskellPackages.ghcWithPackages (
                haskellPackages: with haskellPackages; [
                  xmonad
                  xmonad-contrib
                  aeson
                ]
              ))
            ];
          };
        }
      );

      formatter = utils.eachSystem (system: _: treefmtEval.${system}.config.build.wrapper);
      checks = utils.eachSystem (
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
