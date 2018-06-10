# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  hostName = "rasse-laptop";
in {
  nixpkgs.config.packageOverrides = {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
    };
  };

  imports =
    [
      ("/etc/nixos/hosts/" + hostName + "/hardware-configuration.nix")
      ./pkgs-root.nix
      ("/etc/nixos/hosts/" + hostName)
    ];

  environment.systemPackages = import ./pkgs-global.nix pkgs;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #boot.kernelPackages = pkgs.unstable.linuxPackages_latest;
  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;
  boot.kernelParams = [
    "consoleblank=0"
    #"drm_kms_helper.edid_firmware=edid/1920x1080.bin"
    #"drm.edid_firmware=edid/1920x1080.bin"
    #"psmouse.synaptics_intertouch=1"
  ];

  powerManagement.cpuFreqGovernor = "ondemand";
  powerManagement.powertop.enable = true;

  hardware.opengl.driSupport32Bit = true;

  # Audio
  hardware.bluetooth.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

  # Networking
  networking.hostName = hostName;
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 1234 3000 ];

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  # Allow non-free licenses
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # KDE handles this, enabling both causes trouble at shutdown
  # services.ntp.enable = true;
  
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

  # Hibernate on laptop lid close
  # KDE handles this
  #services.logind.lidSwitch = "hybrid-sleep";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.videoDrivers = [ "nouveau" ];
  #services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.layout = "dvorak";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  #services.xserver.synaptics.enable = false;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.windowManager.xmonad.enable = true;
  #services.xserver.windowManager.xmonad.enableContribAndExtras = true;
  
  #services.xserver.config = ''
  #  Section "InputClass"
  #    Identifier     "Enable libinput for TrackPoint"
  #    MatchIsPointer "on"
  #    Driver         "libinput"
  #  EndSection
  #'';

  services.redshift.enable = true;
  services.redshift.provider = "geoclue2";
  #services.redshift.latitude = "0.0";
  #services.redshift.longitude = "0.0";
  services.redshift.temperature.night = 1900;

  #services.synergy.client.enable = true;
  #services.synergy.client.autoStart = true;
  #services.synergy.client.serverAddress = "192.168.1.234";

  # Android stuff
  programs.adb.enable = true;
  programs.java.enable = true;

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
