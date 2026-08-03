{
  lib,
  config,
  pkgs,
  ...
}:
let
  ffUtils = import ./utils.nix { inherit config lib; };
  firefoxAddons = pkgs.nur.repos.rycee.firefox-addons;

  home-assistant = firefoxAddons.buildFirefoxXpiAddon {
    pname = "home-assistant";
    version = "0.5.0";
    addonId = "home-assistant@bokub.dev";
    url = "https://addons.mozilla.org/firefox/downloads/file/4239570/home_assistant-0.5.0.xpi";
    sha256 = "sha256-Jb6Xqh7Qd/BDokLTRdMVH71pEbOL6Hr/v9n8jX0lm2M=";
    meta = with lib; {
      homepage = "https://github.com/bokub/home-assistant-extension#readme";
      description = "";
      license = licenses.mit;
      mozPermissions = [ ];
      platforms = platforms.all;
    };
  };
  consumer-rights-wiki = firefoxAddons.buildFirefoxXpiAddon {
    pname = "consumer-rights-wiki";
    version = "1.0.35";
    addonId = "@crw-extension-firefox";
    url = "https://addons.mozilla.org/firefox/downloads/file/4790089/consumer_rights_wiki-1.0.35.xpi";
    sha256 = "sha256-AJfCXbBowkajU1FRw71fPOC7nyCYjvZaOkhFVW+ZO0M=";
    meta = with lib; {
      homepage = "https://github.com/FULU-Foundation/CRW-Extension";
      description = "";
      license = licenses.mit;
      mozPermissions = [ "tabs" ];
      platforms = platforms.all;
    };
  };
in
{
  options.firefox = {
    userContent = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  imports = [
    ./search.nix
    ./extensions/darkmode.nix
  ];

  config.programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
  config.programs.firefox.enable = true;
  config.programs.firefox.profiles.${ffUtils.profileName} = {
    id = 0;
    path = "default";
    isDefault = true;

    settings = {
      "browser.aboutwelcome.enabled" = false;
      "network.trr.mode" = 2;
      "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
      "extensions.autoDisableScopes" = 0;
      "ui.key.menuAccessKeyFocuses" = false;
      "browser.ml.linkPreview.enabled" = false;
      "browser.startup.page" = 3; # resume previous session
      "browser.aboutConfig.showWarning" = false;
      "browser.tabs.closeWindowWithLastTab" = false;
      "browser.tabs.fadeOutUnloadedTabs" = true;
      "browser.ctrlTab.sortByRecentlyUsed" = true;
      "browser.toolbars.bookmarks.visibility" = "never";
      "browser.newtabpage.activity-stream.showSponsored" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.newtabWallpapers.wallpaper" = "solid-color-picker-#171717";
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "sidebar.verticalTabs" = true;
      "sidebar.animation.expand-on-hover.delay-duration-ms" = 600;
      "sidebar.animation.expand-on-hover.duration-ms" = 66;
      "sidebar.main.tools" = "syncedtabs,history,bookmarks";
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
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
            (ffUtils.extensionIconEntry firefoxAddons.dark-mode-webextension)
            (ffUtils.extensionIconEntry firefoxAddons.ublock-origin)
            "unified-extensions-button"
            "fxa-toolbar-menu-button"
            (ffUtils.extensionIconEntry home-assistant)
          ];
          "toolbar-menubar" = [ "menubar-items" ];
          "vertical-tabs" = [ "tabbrowser-tabs" ];
          "PersonalToolbar" = [ "personal-bookmarks" ];
        };
        "currentVersion" = 22;
        "newElementCount" = 5;
      };
      "privacy.userContext.newTabContainerOnLeftClick.enabled" = true;
      "devtools.debugger.remote-enabled" = true;
      "devtools.chrome.enabled" = true;
      "devtools.screenshot.clipboard.enabled" = true;
      "devtools.command-button-screenshot.enabled" = true;
    };

    userChrome = builtins.readFile ./user-chrome.css;

    userContent = lib.strings.concatStringsSep "\n" config.firefox.userContent;

    search.force = true;
    containersForce = true;

    extensions.force = true;
    extensions.packages = with firefoxAddons; [
      firenvim
      ublock-origin
      home-assistant
      consumer-rights-wiki
      container-proxy
    ];
  };

  config.firefoxDarkmode.exclude = [
    "teams.cloud.microsoft"
    "github.com"
    "developer.mozilla.org"
    "reddit.com"
    "chatgpt.com"
    "monkeytype.com"
    "nix.dev"
    "doc.rust-lang.org"
  ];

  config.firefox.userContent = [
    ''
      @-moz-document domain("teams.cloud.microsoft") {
        .fui-TeachingPopoverSurface {
          display: none !important;
        }
      }
    ''

    ''
      @-moz-document domain("jira.adbglobal.com") {
        tt {
          border: 1px solid #999;
          border-radius: 0.3em;
          padding: 0 0.3em;
        }
      }
    ''
  ];
}
