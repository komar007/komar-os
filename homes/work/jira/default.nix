{ config, ... }:
{
  imports = [
    ../../modules/jira
  ];

  sops.secrets."password/jira_adb" = { };

  jira.host = "adbglobal.atlassian.net";
  jira.login = "m.trybus@adbglobal.com";
  jira.password = config.sops.placeholder."password/jira_adb";

  jira.config = {
    auth_type = "basic";
    board = {
      id = 220;
      name = "PRISME Roadmap";
      type = "scrum";
    };
    installation = "Cloud";
    project = {
      key = "PRISME";
    };
    timezone = "Europe/Warsaw";
  };
}
