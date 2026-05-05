{
  lib,
  config,
  pkgsDirenvInstant,
  ...
}:
let
  wrappedDirenvInstant =
    final: prev:
    let
      basePackage = pkgsDirenvInstant.direnv-instant;
      wrapped = final.writeShellApplication {
        name = "direnv-instant";
        text = ''
          if [[ $# -ge 2 && $1 == hook && $2 == bash ]]; then
            ${lib.getExe basePackage} "$@"
            # shellcheck disable=SC2016
            printf '%s' ${lib.escapeShellArg config.direnv-instant-wrapped.bashHookPostlude}
          else
            exec ${lib.getExe basePackage} "$@"
          fi
        '';
      };
    in
    {
      direnv-instant-wrapped = wrapped;
    };
in
{
  options.direnv-instant-wrapped.bashHookPostlude = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = "Extra text appended to the output of `direnv-instant hook bash`.";
  };

  config.nixpkgs.overlays = [
    wrappedDirenvInstant
  ];
}
