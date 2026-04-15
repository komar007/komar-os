{
  nur,
  nixgl,
  rust-overlay,
  fshf,
  comma,
  ...
}:
let
  commaEnvWrappedOverlay = (
    final: prev: {
      comma = prev.comma.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/comma \
            --set-default COMMA_PICKER "${final.lib.getExe final.fzf}"
        '';
      });
    }
  );
in
[
  nur.overlays.default
  nixgl.overlay
  rust-overlay.overlays.default
  fshf.overlays.default
  comma.overlays.default
  commaEnvWrappedOverlay
]
