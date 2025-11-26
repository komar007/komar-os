{
  lib,
  config,
  pkgs,
  ...
}:
let
  ff-utils = import ../utils.nix { inherit lib; };
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
in
{
  options.firefox-darkmode = {
    exclude = lib.mkOption {
      type = with lib.types; listOf str;
    };
  };

  config.programs.firefox.profiles."default-release" = {
    extensions.packages = [
      firefox-addons.dark-mode-webextension
    ];

    extensions.settings."${ff-utils.extensionId firefox-addons.dark-mode-webextension}".settings = {
      "custom" = "";
      "state" = "dark";
      "whitelist" = config.firefox-darkmode.exclude;
      "opensupport" = true;
      "cookie" = [
        "ae=d"
        "f6=400"
        "theme=dim"
        "darkmode=1"
        "theme:dark"
        "theme:night"
        "dark_mode=1"
        "nightmode=1"
        "night_mode=1"
        "night_mode=2"
        "theme:darkmode"
        "theme:nightmode"
        "twilight.theme:1"
        "preferredmode:dark"
        "preferredmode:night"
      ];
      "inclusivelist" = [ ];
      "toggleaction" = false;
      "inclusiveaction" = false;
      "scheduleon" = "";
      "scheduleoff" = "";
      "scheduleaction" = false;
      "temporarilydelay" = 200;
      "temporarilyaction" = true;
      "temporarilydisplay" = false;
      "temporarilythreshold" = 1000;
      "temporarilysimpledark" = true;
      "temporarilybrightness" = false;
      "nativecheck" = false;
      "documentroot" = false;
      "nativeinline" = false;
      "nativeignore" = false;
      "nativerespect" = false;
      "nativepriority" = false;
      "nativecontinue" = false;
      "excludeiframes" = false;
      "nativesupports" = false;
      "checkstylesheet" = true;
      "mapcssvariables" = true;
      "nativekeyframes" = false;
      "nativeclassname" = false;
      "nativedeeprules" = false;
      "nativecompatible" = true;
      "nativemediaquery" = false;
      "nativeremoveimage" = true;
      "nativeremovecolor" = false;
      "nativebestpageload" = false;
      "nativebackgroundblend" = true;
      "nativebestperformance" = true;
      "nativebackgroundrelated" = true;
      "nativeperformanceobserver" = false;
      "nativecssstylesheet" = false;
      "nativecssvariables" = {
        "--native-dark-opacity" = "0.85";
        "--native-dark-brightness" = "0.85";
        "--native-dark-bg-color" = "#292929";
        "--native-dark-text-shadow" = "none";
        "--native-dark-font-color" = "#dcdcdc";
        "--native-dark-link-color" = "#8db2e5";
        "--native-dark-cite-color" = "#92de92";
        "--native-dark-fill-color" = "#7d7d7d";
        "--native-dark-accent-color" = "#a9a9a9";
        "--native-dark-border-color" = "#555555";
        "--native-dark-bg-blend-mode" = "multiply";
        "--native-dark-visited-link-color" = "#c76ed7";
        "--native-dark-transparent-color" = "transparent";
        "--native-dark-bg-image-color" = "rgba(0, 0, 0, 0.10)";
        "--native-dark-box-shadow" = "0 0 0 1px rgb(255 255 255 / 10%)";
        "--native-dark-bg-image-filter" = "brightness(50%) contrast(200%)";
      };
      "nativecssrules" = ''
        =root {
          color-scheme: dark !important;
          accent-color: var(--native-dark-accent-color);
        }

        html a:visited,
        html a:visited > *:not(svg) {
          color: var(--native-dark-visited-link-color) !important;
        }

        a[ping]:link,
        a[ping]:link > *:not(svg),
        :link:not(cite) {
          color: var(--native-dark-link-color) !important;
        }

        html cite,
        html cite a:link,
        html cite a:visited {
          color: var(--native-dark-cite-color) !important;
        }

        figure:empty {
          opacity: var(--native-dark-opacity) !important;
        }

        img,
        image {
          filter: brightness(var(--native-dark-brightness)) !important;
        }
      '';
      "nativedarkenimage" = true;
      "nativedarkengradient" = true;
      "nativedarkenvariable" = false;
      "nativedarkenshade" = "linear-gradient(hsla(0, 0%, 0%, 0.85), hsla(0, 0%, 0%, 0.75))";
      "nativerangelimitmin" = 10;
      "nativerangelimitmax" = 90;
      "nativerangethresholdmin" = 10;
      "nativerangethresholdmax" = 75;
      "nativecolorful" = true;
      "nativecolorful-svg" = false;
      "nativecolorful-font" = false;
      "nativecolorful-border" = false;
      "nativecolorful-background" = true;
      "nativeforcefont" = true;
      "nativeforceborder" = true;
      "nativeforcesvgfill" = true;
      "nativeforcesvgstroke" = true;
      "nativeforceboxshadow" = true;
      "nativeforcetextshadow" = true;
      "nativeforcebackground" = true;
      "nativeforceborderwidth" = false;
      "nativeforcetransparency" = true;
      "nativeforcebackgroundcolor" = true;
      "colortemperature" = false;
      "colortemperature-red" = 255;
      "colortemperature-blue" = 199;
      "colortemperature-green" = 227;
      "colortemperature-opacity" = 100;
      "colortemperature-whitelist" = [ ];
      "section-1" = false;
      "section-2" = false;
      "section-3" = false;
      "section-4" = true;
      "section-5" = true;
      "section-6" = false;
      "section-7" = false;
      "dark_1" = false;
      "dark_2" = false;
      "dark_3" = false;
      "dark_4" = false;
      "dark_5" = false;
      "dark_6" = false;
      "dark_7" = false;
      "dark_8" = false;
      "dark_9" = false;
      "dark_10" = false;
      "dark_11" = false;
      "dark_12" = false;
      "dark_13" = false;
      "dark_14" = false;
      "dark_15" = false;
      "dark_16" = false;
      "dark_17" = false;
      "dark_18" = false;
      "dark_19" = false;
      "dark_20" = false;
      "dark_21" = false;
      "dark_22" = false;
      "dark_23" = false;
      "dark_24" = false;
      "dark_25" = false;
      "dark_26" = false;
      "dark_27" = false;
      "dark_28" = false;
      "dark_29" = false;
      "dark_30" = false;
      "dark_31" = false;
      "dark_32" = false;
      "dark_33" = false;
      "dark_34" = false;
      "dark_35" = false;
      "dark_36" = false;
      "dark_37" = false;
      "dark_38" = false;
      "dark_39" = false;
      "dark_40" = false;
      "dark_41" = true;
      "twitch" = true;
      "bing" = true;
      "reddit" = true;
      "amazon" = true;
      "github" = true;
      "tumblr" = true;
      "youtube" = true;
      "dropbox" = true;
      "twitter" = true;
      "ebay" = true;
      "play" = true;
      "facebook" = true;
      "maps" = true;
      "docs" = true;
      "wikipedia" = true;
      "yahoo" = true;
      "gmail" = true;
      "drive" = true;
      "sites" = true;
      "instagram" = true;
      "w3schools" = true;
      "yandex" = true;
      "duckduckgo" = true;
      "telegram" = true;
      "whatsapp" = true;
      "support" = true;
      "accounts" = true;
      "calendar" = true;
      "myaccount" = true;
      "stackoverflow" = true;
      "translate" = true;
      "google" = true;
    };
  };
}
