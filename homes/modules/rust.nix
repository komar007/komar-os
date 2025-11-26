{ pkgs, nixpkgs-unstable, ... }:
{
  home.packages =
    let
      latest-stable-rust = pkgs.rust-bin.stable.latest.default.override {
        extensions = [
          "rust-src"
          "rust-analyzer"
        ];
      };
    in
    with nixpkgs-unstable;
    [
      latest-stable-rust

      cargo-machete
      cargo-nextest
    ];
}
