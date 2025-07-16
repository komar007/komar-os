{ lib, pkgs, ... }:
let
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
  home-assistant = firefox-addons.buildFirefoxXpiAddon {
    pname = "home-assistant";
    version = "0.5.0";
    addonId = "home-assistant@bokub.dev";
    url = "https://addons.mozilla.org/firefox/downloads/file/4239570/home_assistant-0.5.0.xpi";
    sha256 = "sha256-Jb6Xqh7Qd/BDokLTRdMVH71pEbOL6Hr/v9n8jX0lm2M=";
    meta = with lib; {
      homepage = "https://github.com/bokub/home-assistant-extension#readme";
      description = "";
      license = licenses.mit;
      mozPermissions = [];
      platforms = platforms.all;
    };
  };
  ffAddonId = pkg:
  let
    entries = builtins.readDir "${pkg}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/";
    files = builtins.attrNames (lib.filterAttrs (_: type: type == "regular") entries);
    xpis = builtins.filter
      (name: (builtins.match ".*\\.xpi$" name) != null)
      files;
    xpi = builtins.elemAt xpis 0;
  in
    lib.strings.removeSuffix ".xpi" xpi;
  ffAddonIconEntry = pkg:
  let
    id = ffAddonId pkg;
    escaped-id = builtins.replaceStrings [ "{" "}" "@" "." ] [ "_" "_" "_" "_" ] id;
  in
    "${lib.strings.toLower escaped-id}-browser-action";
in
{
  programs.firefox.enable = true;
  programs.firefox.profiles."default-release" = {
    id = 0;
    path = "default";
    isDefault = true;

    settings = {
      "browser.aboutwelcome.enabled" = false;
      "extensions.autoDisableScopes" = 0;
      "ui.key.menuAccessKeyFocuses" = false;
      "browser.aboutConfig.showWarning" = false;
      "browser.tabs.closeWindowWithLastTab" = false;
      "browser.tabs.fadeOutUnloadedTabs" = true;
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "sidebar.verticalTabs" = true;
      "sidebar.animation.expand-on-hover.duration-ms" = 150;
      "sidebar.main.tools" = "syncedtabs,history,bookmarks";
      "browser.uiCustomization.state" = {
        "placements" = {
          "nav-bar" = [
            "sidebar-button"
            "back-button"
            "forward-button"
            "stop-reload-button"
            "customizableui-special-spring1"
            "vertical-spacer"
            "urlbar-container"
            "customizableui-special-spring2"
            "downloads-button"
            (ffAddonIconEntry firefox-addons.dark-mode-webextension)
            (ffAddonIconEntry firefox-addons.ublock-origin)
            "unified-extensions-button"
            "fxa-toolbar-menu-button"
            (ffAddonIconEntry home-assistant)
          ];
          "toolbar-menubar" = [ "menubar-items" ];
          "vertical-tabs" = [ "tabbrowser-tabs" ];
          "PersonalToolbar" = [ "personal-bookmarks" ];
        };
        "currentVersion" = 22;
        "newElementCount" = 5;
      };
      "privacy.userContext.newTabContainerOnLeftClick.enabled" = true;
    };

    containersForce = true;
    containers = {
      home = {
        id = 1;
        color = "blue";
        icon = "chill";
      };
      work = {
        id = 2;
        color = "red";
        icon = "briefcase";
      };
    };

    extensions.settings."${ffAddonId firefox-addons.container-proxy}".settings = {
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

    search.force = true;
    search.engines."Nix Packages" = {
      definedAliases = [ "@np" ];
      urls = [{
        template = "https://search.nixos.org/packages";
        params = [
          { name = "query"; value = "{searchTerms}"; }
        ];
      }];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    };
    search.engines."Nix Options" = {
      definedAliases = [ "@no" ];
      urls = [{
        template = "https://search.nixos.org/options";
        params = [
          { name = "query"; value = "{searchTerms}"; }
        ];
      }];
    };
    search.engines."Home Manager Options" = {
      definedAliases = [ "@hmo" ];
      urls = [{
        template = "https://home-manager-options.extranix.com/";
        params = [
          { name = "query"; value = "{searchTerms}"; }
          { name = "release"; value = "release-25.05"; }
        ];
      }];
    };
    search.engines."crates.io" = {
      definedAliases = [ "@c" ];
      urls = [{
        template = "https://crates.io/search";
        params = [
          { name = "q"; value = "{searchTerms}"; }
        ];
      }];
    };

    extensions.packages = with firefox-addons; [
      firenvim
      ublock-origin
      home-assistant
      container-proxy
      dark-mode-webextension
    ];

    extensions.force = true;
  };
}
