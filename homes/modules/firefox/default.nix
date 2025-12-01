{
  lib,
  config,
  pkgs,
  ...
}:
let
  ff-utils = import ./utils.nix { inherit lib; };
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
      mozPermissions = [ ];
      platforms = platforms.all;
    };
  };
in
{
  options.firefox = {
    userContent = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  imports = [
    ./extensions/darkmode.nix
  ];
  config.programs.firefox.enable = true;
  config.programs.firefox.profiles."default-release" = {
    id = 0;
    path = "default";
    isDefault = true;

    settings = {
      "browser.aboutwelcome.enabled" = false;
      "extensions.autoDisableScopes" = 0;
      "ui.key.menuAccessKeyFocuses" = false;
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
            (ff-utils.extensionIconEntry firefox-addons.dark-mode-webextension)
            (ff-utils.extensionIconEntry firefox-addons.ublock-origin)
            "unified-extensions-button"
            "fxa-toolbar-menu-button"
            (ff-utils.extensionIconEntry home-assistant)
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
    };

    # non-clickable "mute/unmute" playback buttons on background tabs
    userChrome = ''
      tab.tabbrowser-tab:not([selected="true"]) image.tab-icon-overlay[role="presentation"] {
        pointer-events: none;
      }
    '';

    userContent = lib.strings.concatStringsSep "\n" config.firefox.userContent;

    containersForce = true;

    search.force = true;
    search.engines."Nix Packages" = {
      definedAliases = [ "@np" ];
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      iconMapObj."48" = "https://nixos.org/favicon-48x48.png";
    };
    search.engines."Nix Options" = {
      definedAliases = [ "@no" ];
      urls = [
        {
          template = "https://search.nixos.org/options";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      iconMapObj."48" = "https://nixos.org/favicon-48x48.png";
    };
    search.engines."Home Manager Options" = {
      definedAliases = [ "@hmo" ];
      urls = [
        {
          template = "https://home-manager-options.extranix.com/";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
            {
              name = "release";
              value = "release-25.05";
            }
          ];
        }
      ];
      iconMapObj."48" = "https://nixos.org/favicon-48x48.png";
    };
    search.engines."crates.io" = {
      definedAliases = [ "@c" ];
      urls = [
        {
          template = "https://crates.io/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      iconMapObj."227" = "https://crates.io/assets/cargo.png";
    };

    extensions.force = true;
    extensions.packages = with firefox-addons; [
      firenvim
      ublock-origin
      home-assistant
      container-proxy
    ];
  };

  config.firefox-darkmode.exclude = [
    "teams.microsoft.com"
    "github.com"
    "developer.mozilla.org"
    "reddit.com"
    "chatgpt.com"
    "monkeytype.com"
    "nix.dev"
    "doc.rust-lang.org"
  ];
}
