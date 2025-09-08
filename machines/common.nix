{ config, pkgs, nixpkgs-unstable, ...}: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.efi.canTouchEfiVariables = true;

  # systemd-boot is a sane default; disable when needed in specific machines...
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 5;
  };

  time.timeZone = "Europe/Warsaw";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pl_PL.UTF-8";
      LC_IDENTIFICATION = "pl_PL.UTF-8";
      LC_MEASUREMENT = "pl_PL.UTF-8";
      LC_MONETARY = "pl_PL.UTF-8";
      LC_NAME = "pl_PL.UTF-8";
      LC_NUMERIC = "pl_PL.UTF-8";
      LC_PAPER = "pl_PL.UTF-8";
      LC_TELEPHONE = "pl_PL.UTF-8";
      LC_TIME = "pl_PL.UTF-8";
    };
  };
  console.keyMap = "pl2";

  fonts.fontconfig.useEmbeddedBitmaps = true;

  environment.systemPackages = with pkgs; [
    home-manager

    wget
    neovim
    git
    killall
    bc
    zip
    file

    man-pages

    pciutils
    usbutils
    nvme-cli

    openconnect
  ];

  users.users.komar = {
    initialPassword = "test";
    isNormalUser = true;
    description = "Michał Trybus";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  services.kanata = {
    enable = true;
    keyboards."generic".config = builtins.readFile ../kanata-generic.kbd;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
