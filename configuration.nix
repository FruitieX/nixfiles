# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./packages.nix
      ./user-packages.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    #"drm_kms_helper.edid_firmware=edid/1920x1080.bin"
    "drm.edid_firmware=edid/1920x1080.bin"
    "consoleblank=0"
  ];

  hardware.firmware = [
    (pkgs.callPackage ./customEdid {})
    #"/etc/nixos"
    #pkgs.firmwareLinuxNonfree
  ];

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
  networking.hostName = "rasse-laptop"; # Define your hostname.
  networking.networkmanager.enable = true;

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

  # Hibernate on laptop lid close
  services.logind.lidSwitch = "hybrid-sleep";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  #services.xserver.videoDrivers = [ "nouveau" ];
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.layout = "dvorak";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Prefer 120 Hz
  services.xserver.deviceSection = ''
    Option "ConnectedMonitor" "LVDS-0"
    Option "CustomEDID" "LVDS-0:/etc/nixos/customEdid/1920x1080.bin"
    Option "IgnoreEDID" "false"
    Option "UseEDID" "true"
  '';
  services.xserver.monitorSection = ''
    Modeline "1920x1080@120" 285.54 1920 1968 2000 2080 1080 1083 1088 1144 -HSync +Vsync
    Option "PreferredMode" "1920x1080@120"
  '';

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.windowManager.xmonad.enable = true;
  #services.xserver.windowManager.xmonad.enableContribAndExtras = true;

  # Android stuff
  programs.adb.enable = true;
  programs.java.enable = true;

  programs.zsh.enableAutosuggestions = true;
  programs.zsh.enableCompletion = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.rasse = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "docker" "adbusers" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxHyNeiwAzZoExz8iOWkxYmb/3xsN9QVwp/R0/SRUZlFQRPoXk4Ncwkt/U8aiSpm0XmrG1WWGYO9lf5UzAPX8LyHOfjaOyvCTok7RhyMSYZ1cBOJsEQ8MfMRKqjZ0vBaLjRDZoFBERT+/VBfazjTUB1Fv8dGHS8PLvdhMly2VinsSGTc/tApdigP61SJeLmo7NoDavBqTKHx1efJRAw4dRKilhl8fOvAsBCuOn9UzBdZAYX4WTpHvlZGFnkRvLteeAmHGuFPUq8ofc3X4HZfukIz1/l5Ya8l5srHAQEsSpKGcG7EuRHBz+cwEulfjDKlVyFK1Jx7UwJHFGKENtFbST rasse@servy" ];
  };

  services.udev = {
    extraRules = ''
# This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

# This rule is necessary for gamepad emulation
KERNEL=="uinput", SUBSYSTEM="misc", MODE="0666", TAG+="uaccess", OPTIONS+="static_node=uinput"

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

  virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
