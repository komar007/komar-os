{ lib, ... }:
rec {
  extensionId =
    pkg:
    let
      ffId = "ec8030f7-c20a-464f-9b0e-13a3a9e97384";
      entries = builtins.readDir "${pkg}/share/mozilla/extensions/{${ffId}}/";
      files = builtins.attrNames (lib.filterAttrs (_: type: type == "regular") entries);
      xpis = builtins.filter (name: (builtins.match ".*\\.xpi$" name) != null) files;
      xpi = builtins.elemAt xpis 0;
    in
    lib.strings.removeSuffix ".xpi" xpi;

  extensionIconEntry =
    pkg:
    let
      id = extensionId pkg;
      escaped-id = builtins.replaceStrings [ "{" "}" "@" "." ] [ "_" "_" "_" "_" ] id;
    in
    "${lib.strings.toLower escaped-id}-browser-action";
}
