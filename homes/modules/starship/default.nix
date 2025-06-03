{ lib, config, ... }:
{
  config.programs.starship.enable = true;
  config.programs.starship.settings =
    let
      baseConfig = builtins.fromTOML (builtins.readFile ./starship.toml);
    in
    lib.recursiveUpdate baseConfig {
      git_branch.symbol = config.quirks.gitBranchSymbol;
    };
}
