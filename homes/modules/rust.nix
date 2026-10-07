{ pkgs, ... }:
{
  home.packages =
    let
      latestStableRust = pkgs.rust-bin.stable."1.99.0".default.override {
        extensions = [
          "rust-src"
          "rust-analyzer"
        ];
      };
    in
    with pkgs;
    [
      latestStableRust

      cargo-machete
      cargo-nextest
      cargo-binstall
      bacon
    ];
}
