{ lib, config, ... }:
{
  options.netrc =
    let
      entryOptions = {
        login = lib.mkOption { type = lib.types.str; };
        password = lib.mkOption { type = lib.types.str; };
        account = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        # TODO: macdef support?
      };
      machineEntryType =
        with lib.types;
        submodule {
          options = {
            machine = lib.mkOption { type = str; };
          }
          // entryOptions;
        };
      defaultEntryType =
        with lib.types;
        submodule {
          options = entryOptions;
        };
    in
    lib.mkOption {
      type = lib.types.submodule {
        options = {
          entries = lib.mkOption {
            type = with lib.types; listOf machineEntryType;
            default = [ ];
          };
          default = lib.mkOption {
            type = with lib.types; nullOr defaultEntryType;
            default = null;
          };
        };
      };
      default = { };
    };

  config.sops.templates."netrc".content =
    let
      renderCredentials =
        entry:
        lib.concatStringsSep "\n" (
          [
            "login ${entry.login}"
            "password ${entry.password}"
          ]
          ++ lib.optional (entry.account != null) "account ${entry.account}"
        );
      renderMachineEntry =
        entry:
        lib.concatStringsSep "\n" [
          "machine ${entry.machine}"
          (renderCredentials entry)
        ]
        + "\n";
      renderDefaultEntry = entry: "default\n${renderCredentials entry}\n";
    in
    lib.concatMapStringsSep "\n" renderMachineEntry config.netrc.entries
    + lib.optionalString (config.netrc.default != null) (
      "\n" + renderDefaultEntry config.netrc.default
    );

  config.home.file.".netrc".source =
    config.lib.file.mkOutOfStoreSymlink
      config.sops.templates."netrc".path;
}
