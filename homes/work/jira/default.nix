{ config, ... }:
let
  utils = import ../../modules/jira/utils.nix { };
in
{
  imports = [
    ../../modules/jira
  ];

  sops.secrets."password/jira_adb" = { };

  jira.host = "jira.adbglobal.com";
  jira.login = "m.trybus";
  jira.password = config.sops.placeholder."password/jira_adb";

  jira.config = {
    auth_type = "bearer";
    board = {
      id = 548;
      name = "PRISME Roadmap";
      type = "scrum";
    };
    installation = "Local";
    project = {
      key = "PRISME";
    };
    timezone = "Europe/Warsaw";
    issue.types = [
      (utils.task 1 "Bug")
      (utils.task 2 "New Feature")
      (utils.task 3 "Task")
      (utils.task 4 "Improvement")
      (utils.subtask 5 "Sub-task")
      (utils.task 6 "Question")
      (utils.task 7 "Project Issue")
      (utils.task 8 "FIRE & Emergency Issue")
      (utils.subtask 9 "Sub-Issue")
      (utils.task 16 "Epic")
      (utils.task 17 "Story")
      (utils.subtask 18 "Technical task")
      (utils.task 30 "Milestone")
      (utils.subtask 33 "SW release milestone")
      (utils.task 10103 "Risk")
      (utils.task 10500 "Customer Opportunity")
      (utils.task 10601 "Report")
      (utils.task 10900 "Prototype")
    ];
  };
}
