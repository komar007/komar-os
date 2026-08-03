{
  lib,
  config,
  pkgs,
  ...
}:
let
  nixpkgsBaseVersion = builtins.head (builtins.match ''([0-9]+\.[0-9]+).*'' pkgs.lib.version);
  ffUtils = import ./utils.nix { inherit config lib; };
in
{
  programs.firefox.profiles.${ffUtils.profileName}.search.engines = {
    "Nix Packages" = {
      definedAliases = [ "@np" ];
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
            {
              name = "channel";
              value = nixpkgsBaseVersion;
            }
          ];
        }
      ];
      iconMapObj."48" = "https://nixos.org/favicon-48x48.png";
    };
    "Nix Options" = {
      definedAliases = [ "@no" ];
      urls = [
        {
          template = "https://search.nixos.org/options";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
            {
              name = "channel";
              value = nixpkgsBaseVersion;
            }
          ];
        }
      ];
      iconMapObj."48" = "https://nixos.org/favicon-48x48.png";
    };
    "Home Manager Options" = {
      definedAliases = [ "@hmo" ];
      urls = [
        {
          template = "https://home-manager-options.extranix.com/";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
            {
              name = "release";
              value = "release-${nixpkgsBaseVersion}";
            }
          ];
        }
      ];
      iconMapObj."48" = "https://nixos.org/favicon-48x48.png";
    };
    "crates.io" = {
      definedAliases = [ "@c" ];
      urls = [
        {
          template = "https://crates.io/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      iconMapObj."227" = "https://crates.io/_app/immutable/assets/cargo.VCOwdw75.png";
    };
    "jira.adbglobal.com" = {
      definedAliases = [ "@jira" ];
      urls = [
        {
          template = "https://jira.adbglobal.com/browse/{searchTerms}";
        }
      ];
      iconMapObj."128" = "https://jira.adbglobal.com/s/-mn5en6/820014/avp4c6/_/images/fav-jsw.png";
    };

    "nvim-lspconfig" = {
      definedAliases = [ "@lsp" ];
      urls = [
        {
          template = "https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#{searchTerms}";
        }
      ];
    };
  };
}
