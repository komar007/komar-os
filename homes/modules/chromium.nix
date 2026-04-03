{ lib, config, ... }:
{
  options.chromium.enableVaapiIntelFeatures = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  options.chromium.enableVaapiAmdFeatures = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config.programs.chromium.enable = true;
  config.programs.chromium.commandLineArgs =
    let
      # found on an Arch forum
      intelFeatures =
        if config.chromium.enableVaapiIntelFeatures then
          [
            "AcceleratedVideoDecodeLinuxGL"
          ]
        else
          [ ];
      # meticulously selected via trial-and-error and arcane Arch forums reading
      amdFeatures =
        if config.chromium.enableVaapiAmdFeatures then
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
