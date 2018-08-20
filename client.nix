# This file contains configs that are shared across "client" hosts
# (laptops, desktop computers)

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in {
  nixpkgs.config.packageOverrides = {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
    };
  };

  environment.systemPackages = with pkgs; [
    # Dev stuff
    unstable.android-studio

    # qdbus lives in qttools
    unstable.qt5.qttools

    # Windows crap
    wine
    winetricks

    # GUI stuff
    rofi
    xorg.xkill
    terminus_font
    unstable.ark
    unstable.firefox
    unstable.google-chrome
    unstable.alacritty
    unstable.xorg.xmodmap
    unstable.gimp
    unstable.rawtherapee
    unstable.nitrogen
    unstable.synergy
    unstable.okular
    unstable.filezilla
    unstable.kdeApplications.kio-extras               # MTP support for Dolphin
    unstable.steam
    unstable.vlc
    libreoffice-fresh
    lm_sensors
  ];

  # Enable Bluetooth support
  hardware.bluetooth.enable = true;

  # Audio
  hardware.pulseaudio = {
    # Steam & co. needs this
    support32Bit = true;

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;

    # Discover PulseAudio sinks on the local network
    zeroconf.discovery.enable = true;

    # Tweak the latency offset of a certain Bluetooth speaker
    #extraConfig = ''
      #set-port-latency-offset bluez_card.B8_D5_0B_E5_11_22 speaker-output 30000

    #  load-module module-null-sink sink_name=rtp
    #  load-module module-rtp-send source=rtp.monitor destination_ip=192.168.1.101
    #'';
  };

  # PulseAudio needs a restart after resume to fix Bluetooth audio
  powerManagement.resumeCommands = "killall pulseaudio";

  # Suspend when lid closed
  services.logind.lidSwitch = "suspend";

  # Steam & co. needs this
  hardware.opengl.driSupport32Bit = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "dvorak";

  # Use libinput
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.windowManager.herbstluftwm.enable = true;

  # Enable GNOME 3
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.gdm.wayland = true;
  #services.xserver.desktopManager.gnome3.enable = true;

  # Adjust display color temperature during nighttime
  services.redshift.enable = true;
  services.redshift.provider = "geoclue2";
  services.redshift.temperature.night = 1900;

  # Nice bootup screen
  # TODO: Disabled as this causes problems with X.org after wakeup from suspend
  #boot.plymouth.enable = true;

  # Android stuff
  programs.adb.enable = true;
  programs.java.enable = true;
  #users.extraUsers.rasse.extraGroups = ["adbusers"];

  # Steam controller udev rules
  # TODO: maybe move this elsewhere
  services.udev = {
    extraRules = ''
      # This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
      SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

      # This rule is necessary for gamepad emulation
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

}
