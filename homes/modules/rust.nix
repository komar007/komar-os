{ pkgs, pkgsUnstable, ... }:
{
  home.packages =
    let
      latestStableRust = pkgs.rust-bin.stable.latest.default.override {
        extensions = [
          "rust-src"
          "rust-analyzer"
        ];
      };
    in
    with pkgsUnstable;
    [
      latestStableRust

      cargo-machete
      cargo-nextest
      cargo-binstall
      bacon
    ];
}
