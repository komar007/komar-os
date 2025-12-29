{ ... }:
{
  programs.ssh.matchBlocks.work-pc = {
    host = "work-vpn";
    hostname = "192.168.134.42";
    proxyJump = "adb-jumphost";
    port = 22;
    user = "komar";
    forwardX11 = true;
  };
  programs.ssh.matchBlocks.adb-jumphost = {
    host = "adb-jumphost";
    hostname = "192.168.5.68";
    port = 22;
    user = "M.Trybus";
  };
  programs.ssh.matchBlocks.work-pc-tunnel = {
    host = "work";
    hostname = "localhost";
    port = 9022;
    user = "komar";
    forwardX11 = true;
  };
}
