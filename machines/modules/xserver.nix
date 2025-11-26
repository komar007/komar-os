{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    xkb = {
      layout = "pl";
    };
  };

  system.replaceDependencies.replacements = [
    {
      original = pkgs.xorg.xorgserver;
      replacement = pkgs.xorg.xorgserver.overrideAttrs (old: {
        patches = old.patches ++ [
          (pkgs.fetchpatch {
            url = "https://github.com/komar007/xserver/compare/xorg-server-21.1.16...xorg-server-21.1.16_no_tear.patch";
            sha256 = "sha256-zihVEOHX7BjlMjPu9WwyAUBnd5JWViuJ2jrtwC6Dbfc=";
          })
        ];
      });
    }
  ];
}
