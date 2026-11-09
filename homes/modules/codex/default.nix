{ config, pkgsUnstable, ... }:
{
  programs.codex.enable = true;
  programs.codex.package = pkgsUnstable.codex;
  programs.codex.settings = {
    model = "gpt-6.1-sol";
    model_reasoning_effort = "high";

    projects =
      let
        home = config.home.homeDirectory;
      in
      {
        "${home}/repos/dot-nvim".trust_level = "trusted";
        "${home}/repos/komar-os".trust_level = "trusted";
        "${home}/repos/dot-tmux".trust_level = "trusted";
        "${home}/temp".trust_level = "trusted";
      };

    tui = {
      animations = false;
      #ghost_suggestions = false;
      screen_reader_detection_done = true;
      status_line = [
        "model-with-reasoning"
        "current-dir"
        "thread-name"
        "five-hour-limit"
        "weekly-limit"
      ];
      status_line_use_colors = true;
      copy_on_select = "always";
      terminal_title = [
        "app-name"
        "activity"
        "thread-name"
        "project-name"
      ];

      model_availability_nux = {
        "gpt-5.5" = 4;
        "gpt-5.6-sol" = 3;
        "gpt-6.1-sol" = 4;
      };
    };

    features = {
      inline_suggestions = false;
    };
  };
}
#pkgsUnstable.codex
