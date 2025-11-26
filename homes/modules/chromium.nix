{ lib, config, ... }:
{
  options.chromium.enable-vaapi-intel-features = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  options.chromium.enable-vaapi-amd-features = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config.programs.chromium.enable = true;
  config.programs.chromium.commandLineArgs =
    let
      # found on an Arch forum
      intelFeatures =
        if config.chromium.enable-vaapi-intel-features then
          [
            "AcceleratedVideoDecodeLinuxGL"
          ]
        else
          [ ];
      # meticulously selected via trial-and-error and arcane Arch forums reading
      amdFeatures =
        if config.chromium.enable-vaapi-amd-features then
          [
            "VaapiIgnoreDriverChecks"
            "Vulkan"
            "DefaultANGLEVulkan"
            "VulkanFromANGLE"
          ]
        else
          [ ];
      features = lib.strings.concatStringsSep "," (intelFeatures ++ amdFeatures);
      enableFeatures = "--enable-features=" + features;
    in
    [ enableFeatures ];
}
