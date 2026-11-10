{ lib, config, ... }:
let
  ffUtils = import ./utils.nix { inherit config lib; };
in
{
  programs.firefox.profiles.${ffUtils.profileName}.settings = {
    "browser.newtabpage.activity-stream.topSitesRows" = 1;
    "browser.newtabpage.pinned" = [
      {
        label = "gerrit";
        url = "https://gerrit.adbgroup.pl/dashboard/self";
      }
      {
        label = "Meteo";
        url = "https://app.meteo.pl/meteogram/50.29,18.67";
      }
      { }
      { }
      { }
      { }
      { }
      { }
    ];
  };
}
