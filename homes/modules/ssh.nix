{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      identityFile = "/run/secrets/users/komar/ssh_key";
      serverAliveInterval = 100;
      serverAliveCountMax = 3;
    };
  };
}
