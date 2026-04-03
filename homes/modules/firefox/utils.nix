{ lib, config, ... }:
rec {
  profileName = "default-release";

  # the firefox extension id of the firefox extension contained in pkg.
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

  # an element of config.programs.firefox.profiles.*.settings."browser.uiCustomization.state".placements.nav-bar
  # that produces an access icon for the firefox extension contained in pkg.
  extensionIconEntry =
    pkg:
    let
      id = extensionId pkg;
      escapedId = builtins.replaceStrings [ "{" "}" "@" "." ] [ "_" "_" "_" "_" ] id;
    in
    "${lib.strings.toLower escapedId}-browser-action";

  # the storage.js file path (relative to the home directory) containing an extension's settings
  # in other words, the path of the output produced by
  # programs.firefox.profiles.<profile>.extensions.settings.<extensionId>.settings
  extensionSettingsFile =
    let
      profileDir = config.programs.firefox.profiles.${profileName}.path;
    in
    pkg: ".mozilla/firefox/${profileDir}/browser-extension-data/${extensionId pkg}/storage.js";
}
