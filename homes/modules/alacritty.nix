{ lib, config, ... }:
{
  options.alacritty = {
    font = lib.mkOption {
      type = lib.types.str;
    };
    font-italic = lib.mkOption {
      type = lib.types.str;
      default = config.alacritty.font;
    };
    font-size = lib.mkOption {
      type = lib.types.float;
    };
    font-offset = lib.mkOption {
      type = lib.types.int;
      default = -4;
    };
    glyph-offset = lib.mkOption {
      type = lib.types.int;
      default = -2;
    };
  };

  config.programs.alacritty.enable = true;
  config.programs.alacritty.settings = {
    scrolling.history = 32768;
    scrolling.multiplier = 5;

    bell.animation = "EaseOutExpo";
    bell.color = "#444444";
    bell.duration = 60;

    cursor.style.blinking = "Always";

    mouse.hide_when_typing = true;

    colors = {
      cursor.cursor = "CellForeground";
      cursor.text = "CellBackground";

      normal.black = "#7c6f64";
      normal.blue = "#83a5d8";
      normal.cyan = "#8ec07c";
      normal.green = "#c5c821";
      normal.magenta = "#d3869b";
      normal.red = "#fb4934";
      normal.white = "#ebdbb2";
      normal.yellow = "#fabd2f";

      primary.background = "#000000";
      primary.bright_foreground = "#f9f5d7";
      primary.dim_foreground = "#f2e5bc";
      primary.foreground = "#fbf1c7";

      selection.background = "CellForeground";
      selection.text = "CellBackground";

      vi_mode_cursor.cursor = "CellForeground";
      vi_mode_cursor.text = "CellBackground";
    };

    font = {
      size = config.alacritty.font-size;

      normal.family = config.alacritty.font;
      normal.style = "Light";

      bold.family = config.alacritty.font;
      bold.style = "Bold";

      italic.family = config.alacritty.font-italic;
      italic.style = "Italic";

      bold_italic.family = config.alacritty.font-italic;
      bold_italic.style = "Bold Italic";

      offset.y = config.alacritty.font-offset;

      glyph_offset.y = config.alacritty.glyph-offset;
    };

    window = {
      opacity = 0.7;
    };

    keyboard.bindings = [
      # unbind unnecessary defaults
      {
        mods = "Control";
        key = "-";
        action = "None";
      }
      {
        mods = "Control";
        key = "=";
        action = "None";
      }

      {
        mods = "Control | Shift";
        key = "_";
        action = "DecreaseFontSize";
      }
      {
        mods = "Control | Shift";
        key = "+";
        action = "IncreaseFontSize";
      }
      {
        mods = "Control | Shift";
        key = "|";
        action = "ResetFontSize";
      }

      {
        # nvim: yank deleted lines in git diff
        mods = "Control|Shift";
        key = "y";
        chars = "\\uE105";
      }
      {
        # nvim: history back in picker
        mods = "Control|Shift";
        key = "p";
        chars = "\\uE106";
      }
      {
        # nvim: history forward in picker
        mods = "Control|Shift";
        key = "n";
        chars = "\\uE107";
      }
    ];
  };
}
