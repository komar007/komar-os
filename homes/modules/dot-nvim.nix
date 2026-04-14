{ config, dotNvimModule, ... }:
{
  imports = [
    dotNvimModule
  ];

  dot-nvim.quirks.gitBranchSymbol = config.quirks.gitBranchSymbol;
}
