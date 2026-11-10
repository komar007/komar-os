{ ... }:
{
  config.programs.thunderbird.enable = true;
  config.programs.thunderbird.profiles."default" = {
    isDefault = true;

    settings = {
      "mail.shell.checkDefaultClient" = false;
      "mail.pane_config.dynamic" = 1; # wide e-mail preview, under e-mail list
      "mail.threadpane.listview" = 1; # table view
      "mail.tabs.drawInTitlebar" = false; # remove window management anti-feature
      "mailnews.default_sort_order" = 1; # ascending

      "ui.systemUsesDarkTheme" = 1;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    };

    userChrome = builtins.readFile ./user-chrome.css;
  };
}
