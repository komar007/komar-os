{ ... }:
{
  programs.starship.enable = true;
  programs.starship.settings = builtins.fromTOML (builtins.readFile ./starship.toml);
}
