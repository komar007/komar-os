{ lib, pkgs, ... }:
let
  ff-utils = import ../utils.nix { inherit lib; };
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  programs.firefox.profiles."default-release" = {
    containers.home = {
      id = 1;
      color = "blue";
      icon = "chill";
    };

    extensions.settings."${ff-utils.extensionId firefox-addons.container-proxy}".settings = {
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
