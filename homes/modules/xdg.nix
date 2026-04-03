{ lib, config, ... }:
{
  options.xdg = {
    defaultBrowserApp = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.xdg.mimeApps = {
    enable = true;

    defaultApplications =
      let
        browserApp = config.xdg.defaultBrowserApp;
      in
      {
        "text/html" = browserApp;
        "x-scheme-handler/http" = browserApp;
        "x-scheme-handler/https" = browserApp;
        "x-scheme-handler/about" = browserApp;
        "x-scheme-handler/unknown" = browserApp;
      };
  };

}
