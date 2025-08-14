{ lib, pkgs, ... }: {
  programs.firefox.profiles."default-release".settings = {
    "browser.newtabpage.pinned" = [
      { label = "Google Keep"; url = "https://keep.google.com"; }
      { label = "Home Assistant"; url = "http://192.168.88.5:8123/lovelace-test/default_view"; }
      { label = "Voron 2.4R2"; url = "https://192.168.88.94"; }
      { }
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
