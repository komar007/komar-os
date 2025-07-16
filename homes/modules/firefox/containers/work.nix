{ lib, pkgs, ... }:
let
  ff-utils = import ../utils.nix { inherit lib; };
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  programs.firefox.profiles."default-release" = {
    containers.work = {
      id = 2;
      color = "red";
      icon = "briefcase";
    };

    extensions.settings."${ff-utils.extensionId firefox-addons.container-proxy}".settings = {
      proxies = [
        {
          id = "efc535d3-740d-4b69-8374-6bf4e303b661";
          title = "work";
          type = "socks";
          host = "localhost";
          port = 9999;
          doNotProxyLocal = true;
          proxyDNS = true;
        }
      ];
      relations = {
        "firefox-container-2" = [ "efc535d3-740d-4b69-8374-6bf4e303b661" ];
      };
    };
  };
}
