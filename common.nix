{ config, pkgs, ... }:

let
  hostname = import ./hostname.nix;
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in {
  nixpkgs.config.packageOverrides = {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the most recent kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Power management
  powerManagement.cpuFreqGovernor = "ondemand";
  powerManagement.powertop.enable = true;

  # Audio
  hardware.pulseaudio = {
    enable = true;

    # Enable tcp streaming support
    tcp.enable = true;
  };

  # Networking
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts = [ 1234 3000 ];

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  # Allow non-free licenses
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";
  
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    passwordAuthentication = false;
  };

  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "10s";
        static_configs = [
          {
            targets = [
              "localhost:9100"
            ];
            labels = {
              alias = "prometheus.fruitiex.org";
            };
          }
        ];
      }
    ];
    exporters.node = {
      enable = true;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
    };
  };
  services.grafana = {
    enable = true;
    port = 4000;
  };

  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.rasse = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "docker" "adbusers" "vboxusers" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxHyNeiwAzZoExz8iOWkxYmb/3xsN9QVwp/R0/SRUZlFQRPoXk4Ncwkt/U8aiSpm0XmrG1WWGYO9lf5UzAPX8LyHOfjaOyvCTok7RhyMSYZ1cBOJsEQ8MfMRKqjZ0vBaLjRDZoFBERT+/VBfazjTUB1Fv8dGHS8PLvdhMly2VinsSGTc/tApdigP61SJeLmo7NoDavBqTKHx1efJRAw4dRKilhl8fOvAsBCuOn9UzBdZAYX4WTpHvlZGFnkRvLteeAmHGuFPUq8ofc3X4HZfukIz1/l5Ya8l5srHAQEsSpKGcG7EuRHBz+cwEulfjDKlVyFK1Jx7UwJHFGKENtFbST rasse@servy" ];
  };

  # Steam controller udev rules
  # TODO: move this elsewhere
  services.udev = {
    extraRules = ''
# This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

# This rule is necessary for gamepad emulation
#KERNEL=="uinput", SUBSYSTEM="misc", MODE="0666", TAG+="uaccess", OPTIONS+="static_node=uinput"
KERNEL=="uinput", MODE="0660", GROUP="users", OPTIONS+="static_node=uinput"
KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", TAG+="udev-acl"

# Valve HID devices over USB hidraw
KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"

# Valve HID devices over bluetooth hidraw
KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"

# DualShock 4 over USB hidraw
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"

# DualShock 4 wireless adapter over USB hidraw
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0666"

# DualShock 4 Slim over USB hidraw
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"

# DualShock 4 over bluetooth hidraw
KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0666"

# DualShock 4 Slim over bluetooth hidraw
KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0666"

# Nintendo Switch Pro Controller over USB hidraw
KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"

# Nintendo Switch Pro Controller over bluetooth hidraw
KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0666"
    '';
  };

  # Virtualisation
  # virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
