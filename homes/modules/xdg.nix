{ lib, config, ... }:
{
  options.xdg = {
    default-browser-app = lib.mkOption {
      type = lib.types.str;
    };
  };

  config.xdg.mimeApps = {
    enable = true;

    defaultApplications =
      let
        browser-app = config.xdg.default-browser-app;
      in
      {
        "text/html" = browser-app;
        "x-scheme-handler/http" = browser-app;
        "x-scheme-handler/https" = browser-app;
        "x-scheme-handler/about" = browser-app;
        "x-scheme-handler/unknown" = browser-app;
      };
  };

}
