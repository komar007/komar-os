{ lib, config, ... }:
{
  options.xdg = {
    defaultBrowserApp = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
    };
  };

  config.xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browserApp = config.xdg.defaultBrowserApp;
      in
      lib.optionalAttrs (browserApp != null) {
        "text/html" = browserApp;
        "x-scheme-handler/http" = browserApp;
        "x-scheme-handler/https" = browserApp;
        "x-scheme-handler/about" = browserApp;
        "x-scheme-handler/unknown" = browserApp;
      };
  };
}
