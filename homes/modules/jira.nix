{ config, pkgs, ... }:
let
  p = config.sops.placeholder;
  toYAML = (pkgs.formats.yaml { }).generate "whocares.yml";
in
{
  imports = [
    ./netrc.nix
  ];

  sops.secrets."password/jira_adb" = { };

  home.file.".config/.jira/.config.yml".source = toYAML {
    auth_type = "bearer";
    board = {
      id = 548;
      name = "PRISME Roadmap";
      type = "scrum";
    };
    installation = "Local";
    login = "m.trybus";
    project = {
      key = "PRISME";
    };
    server = "https://jira.adbglobal.com";
    timezone = "Europe/Warsaw";
  };

  netrc.entries = [
    {
      machine = "jira.adbglobal.com";
      login = "m.trybus";
      password = "${p."password/jira_adb"}";
    }
  ];

  home.packages = with pkgs; [
    jira-cli-go
  ];
}
