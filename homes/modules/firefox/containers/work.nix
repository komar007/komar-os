{ lib, pkgs, ... }:
{
  programs.firefox.profiles."default-release" = {
    containers.work = {
      id = 2;
      color = "red";
      icon = "briefcase";
    };
  };
}
