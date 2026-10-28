{ ... }:
{
  config.programs.thunderbird.enable = true;
  config.programs.thunderbird.profiles."default" = {
    isDefault = true;

    settings = {
      "ui.systemUsesDarkTheme" = 1;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };

    userChrome = builtins.readFile ./user-chrome.css;
  };
}
