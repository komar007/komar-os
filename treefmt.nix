{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  settings.formatter.nixfmt.excludes = [ "machines/*/hardware-configuration.nix" ];

  programs.shfmt.enable = true;
  programs.shfmt.useEditorConfig = true;
}
