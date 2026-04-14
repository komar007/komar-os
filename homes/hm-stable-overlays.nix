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
    final: prev:
    let
      shortFirstFzf = final.writeShellApplication {
        name = "shortFirstFzf";
        runtimeInputs = with final; [
          coreutils
          gawk
          fzf
        ];
        text = ''
          awk '{ print length, $0 }' |
            sort -k1,1n -k2,2r |
            cut -d' ' -f2- |
            fzf
        '';
      };
    in
    {
      comma = prev.comma.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram $out/bin/comma \
            --set-default COMMA_PICKER "${final.lib.getExe shortFirstFzf}"
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
