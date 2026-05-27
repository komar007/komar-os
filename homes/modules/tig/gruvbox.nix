{
  config,
  lib,
  pkgs,
  ...
}:
let
  doLines =
    f: text:
    let
      inputLines = lib.splitString "\n" text;
    in
    builtins.concatStringsSep "\n" (f inputLines);
  upstreamTigrc = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/ninjabreakbot/tig-gruvbox/f83785a09461747baa3a5dc7609a7edf1087d8dc/tigrc";
    sha256 = "09vf3f4zwdqi4imhb5fgykm4ypbhx9z1lkwlv8j4b2ydfm6c38j2";
  };
  upstreamColors = doLines (builtins.filter (
    line: !isNull (builtins.match "^color.*|^(#.*)?$" line)
  )) (builtins.readFile upstreamTigrc);
  normalized =
    text:
    let
      file = pkgs.writeText "x" text;
    in
    pkgs.runCommand "normalize" {
      nativeBuildInputs = [ pkgs.gnused ];
    } ''sed -r 's/[ \t]+/ /g' ${file} >"$out"'';
in
{
  options.tig-gruvbox = {
    extra = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
    };
  };
  config.home.file.".config/tig/config".source = normalized (
    upstreamColors
    + "\n\n# nix extra\n"
    + builtins.concatStringsSep "\n" (map (c: "color ${c}") config.tig-gruvbox.extra)
    + "\n"
  );
}
