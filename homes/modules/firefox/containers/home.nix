{
  lib,
  config,
  pkgs,
  ...
}:
let
  ffUtils = import ../utils.nix { inherit config lib; };
  firefoxAddons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  programs.firefox.profiles.${ffUtils.profileName} = {
    containers.home = {
      id = 1;
      color = "blue";
      icon = "chill";
    };

    extensions.settings."${ffUtils.extensionId firefoxAddons.container-proxy}".settings = {
      proxies = [
        {
          id = "8b1964af-23a7-43c7-b7cb-828ad3f2ab31";
          title = "home";
          type = "socks";
          host = "localhost";
          port = 9998;
          doNotProxyLocal = true;
          proxyDNS = true;
        }
      ];
      relations = {
        "firefox-container-1" = [ "8b1964af-23a7-43c7-b7cb-828ad3f2ab31" ];
      };
    };
  };
}
