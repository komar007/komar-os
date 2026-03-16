{ config, inputs, ... }:
{
  nixGL.packages = inputs.nixgl.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = [ "mesa" ];
  nixGL.vulkan.enable = true;

  nixpkgs.overlays =
    let
      makeNixGlWrappedOverlay =
        pkgs: final: prev:
        builtins.listToAttrs (
          map (pkg: {
            name = pkg;
            value = config.lib.nixGL.wrap prev.${pkg};
          }) pkgs
        );
    in
    [
      (makeNixGlWrappedOverlay [
        "alacritty"
        "mpv"
        "firefox"
        "qutebrowser"
        "geeqie"
      ])
    ];
}
