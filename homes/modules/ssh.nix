{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      serverAliveInterval = 100;
      serverAliveCountMax = 3;
    };
  };
}
