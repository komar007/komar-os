{ ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    extraConfig.pipewire-pulse."10-auto-connect" = {
      "pulse.cmd" = [
        {
          cmd = "load-module";
          args = "module-switch-on-connect";
        }
      ];
    };
  };
}
