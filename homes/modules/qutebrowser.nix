{ ... }:
{
  programs.qutebrowser.enable = true;
  programs.qutebrowser.loadAutoconfig = true;

  programs.qutebrowser.keyBindings.normal = {
    "<Ctrl+->" = "tab-focus last";
    "<Ctrl+Shift+j>" = "tab-move +";
    "<Ctrl+Shift+k>" = "tab-move -";
    "<Ctrl+Shift+l>" = "cmd-set-text :open {url:pretty}";
    "<Ctrl+i>" = "forward";
    "<Ctrl+j>" = "tab-next";
    "<Ctrl+k>" = "tab-prev";
    "<Ctrl+l>" = "cmd-set-text -s :open";
    "<Ctrl+o>" = "back";
    "<Ctrl+p>" = "cmd-set-text -s :tab-select";
    "<Ctrl+t>" = "cmd-set-text -s :open -t";
    "H" = "nop";
    "J" = "nop";
    "K" = "nop";
    "L" = "nop";
  };
  programs.qutebrowser.keyBindings.command = {
    "<Ctrl+n>" = "completion-item-focus next";
    "<Ctrl+p>" = "completion-item-focus prev";
  };

  programs.qutebrowser.settings = {
    auto_save.session = true;
    colors.webpage.darkmode.enabled = true;
    colors.tabs.bar.bg = "#111111";
    colors.tabs.even.bg = "#000000";
    colors.tabs.even.fg = "#555555";
    colors.tabs.odd.bg = "#000000";
    colors.tabs.odd.fg = "#555555";
    colors.tabs.selected.even.bg = "#000000";
    colors.tabs.selected.even.fg = "#8da2dc";
    colors.tabs.selected.odd.bg = "#000000";
    colors.tabs.selected.odd.fg = "#8da2dc";
    statusbar.show = "in-mode";
    tabs.max_width = 300;
    tabs.position = "bottom";
    tabs.show = "multiple";
  };

  programs.qutebrowser.extraConfig = ''
    c.url.searchengines = {
      "DEFAULT": "https://duckduckgo.com/?q={}",
      "jira": "https://jira.adbglobal.com/browse/{}",
    }
  '';
}
