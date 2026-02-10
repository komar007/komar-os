{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "teams";
      runtimeInputs = with pkgs; [ chromium ];
      text = ''
        chromium --kiosk https://teams.microsoft.cloud \
            --user-data-dir="$HOME"/.local/share/teams/ \
            --no-first-run \
            --no-default-browser-check \
            --disable-sync \
            --disable-extensions \
            --disable-features=TranslateUI,PasswordImport
      '';
    })
  ];
}
