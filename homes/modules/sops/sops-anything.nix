# This module allows to use a sops placeholder in any home-manager string option as long as the user
# knows the name(s) of the generated file(s) that will end up containing that option value and the
# placeholder is known not to be mangled in the process.
#
# It works by disabling generation of given output files in the home directory, using their
# generated content as a sops template and then adding an alternative output file definition that
# links to the rendered template instead.
#
# It requires that any file F is defined using home.file.${F}, which may not always be the case (for
# example home.file.xxx = { target = F, ...}), and assumes the user knows the exact name of a
# generated file, which may be an implementation detail of a module that generates it.

{ config, lib, ... }:
let
  mergeAttrsFor = xs: f: builtins.foldl' (acc: x: acc // (f x)) { } xs;
  # id used both as sops template name and home.file entry name (not target!)
  idFor = file: "__sops-anything__/${file}";
in
{
  options.sops-anything.home-files = lib.mkOption {
    type = with lib.types; listOf str;
    description = "list of output files in the home directory known to contain sops placeholders";
  };

  config.home.file = mergeAttrsFor config.sops-anything.home-files (file: {
    # disable file generation and use its content as a sops-nix template
    ${file}.enable = false;

    # link rendered template back to the original target
    ${idFor file} = {
      target = file;
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates.${idFor file}.path;
    };
  });

  config.sops.templates = mergeAttrsFor config.sops-anything.home-files (file: {
    # TODO: what if .text is not available? can we use source instead?
    ${idFor file}.content = config.home.file.${file}.text;
  });
}
