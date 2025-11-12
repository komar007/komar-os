{ lib, pkgs, config, ... }:
{
  home.packages =
  let
    latest-stable-rust = pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" ];
    };
  in
    [ latest-stable-rust ];
}
