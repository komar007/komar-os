{ inputs, ... }:
let
  wrappedCommaOverlay =
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
    };
in
{
  imports = [
    inputs.nix-index-database.homeModules.default
  ];

  nixpkgs.overlays = [
    # first, the newer version of comma...
    inputs.comma.overlays.default
    # ... then our wrapper
    wrappedCommaOverlay
  ];

  programs.nix-index-database.comma.enable = true;
  programs.nix-index.enableBashIntegration = false;
}
