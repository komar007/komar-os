{
  lib,
  config,
  pkgs,
  ...
}:
let
  toYAML = (pkgs.formats.yaml { }).generate "whocares.yml";
in
{
  imports = [
    ../../modules/netrc.nix
  ];

  options.jira = {
    host = lib.mkOption {
      type = lib.types.str;
      description = "jira host without http(s) schema";
    };
    login = lib.mkOption { type = lib.types.str; };
    password = lib.mkOption { type = lib.types.str; };
    config = lib.mkOption { };
  };

  config.home.file.".config/.jira/.config.yml".source = toYAML config.jira.config;

  config.jira.config = {
    login = lib.strings.toLower config.jira.login;
    # jira-cli expects a URI as server address...
    server = "https://${config.jira.host}";
  };

  config.netrc.entries = [
    {
      # ... while it looks it up by host in netrc
      machine = config.jira.host;
      login = config.jira.config.login;
      password = config.jira.password;
    }
  ];

  config.home.packages = with pkgs; [
    jira-cli-go
  ];
}
