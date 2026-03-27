{ lib, ... }:
let
  ff-utils = import ../utils.nix { inherit lib; };
in
{
  programs.firefox.profiles.${ff-utils.profileName}.settings = {
    "browser.newtabpage.pinned" = [
      {
        label = "Gmail";
        url = "https://mail.google.com/mail/u/0/#inbox";
      }
      {
        label = "Google Keep";
        url = "https://keep.google.com";
      }
      {
        label = "Messenger";
        url = "https://www.messenger.com/";
      }
      {
        label = "Whatsapp";
        url = "https://web.whatsapp.com/";
      }
      {
        label = "Discord";
        url = "https://discord.com/app";
      }
      { }
      {
        label = "Home Assistant";
        url = "http://192.168.88.5:8123/lovelace-test/default_view";
      }
      {
        label = "Voron 2.4R2";
        url = "http://192.168.88.94";
      }
      { }
      { }
      { }
      { }
      { }
      { }
      { }
    ];
  };
}
