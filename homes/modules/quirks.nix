{ lib, ... }:
{
  options.quirks = {
    gitBranchSymbol = lib.mkOption {
      type = lib.types.str;
      description = "symbol used to represent a git branch (may be different in different fonts)";
      default = "⎇";
    };
  };
}
