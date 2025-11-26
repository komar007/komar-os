{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    amdgpu_top
  ];
}
