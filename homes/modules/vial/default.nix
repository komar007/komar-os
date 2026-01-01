{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "vial";
      runtimeInputs = with pkgs; [ chromium ];
      text = ''
        chromium --kiosk https://vial.rocks \
            --user-data-dir="$HOME"/.local/share/vial/ \
            --no-first-run \
            --no-default-browser-check \
            --disable-sync \
            --disable-extensions \
            --disable-features=TranslateUI,PasswordImport
      '';
    })
  ];
}
