{ pkgs, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      vpl-gpu-rt
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];
}
