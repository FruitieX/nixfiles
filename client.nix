# This file contains configs that are shared across "client" hosts
# (laptops, desktop computers)

{ config, pkgs, user, ... }:

{
  # Add desktop packages
  environment.systemPackages = with pkgs; [
    desktopToolsEnv
  ];

  # Attempt resolving DNS problems
  services.resolved.enable = true;
  services.resolved.fallbackDns = ["1.1.1.1"];

  # Flatpak support: https://github.com/NixOS/nixpkgs/pull/33371
  services.flatpak.enable = true;

  # Install flatpak packages
  system.activationScripts.flatpak-install = import ./scripts/flatpak-install.nix {
    inherit pkgs;
    inherit user;
    flatpakPackages = [
      "com.discordapp.Discord"
      "com.spotify.Client"
      "com.valvesoftware.Steam"
      "org.darktable.Darktable"
      "org.filezillaproject.Filezilla"
      "org.gimp.GIMP"
      "org.libreoffice.LibreOffice"
      "org.videolan.VLC"
    ];
  };

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

    extraConfig = ''
      load-module module-switch-on-connect
    '';

    # Tweak the latency offset of a certain Bluetooth speaker
    #extraConfig = ''
      #set-port-latency-offset bluez_card.B8_D5_0B_E5_11_22 speaker-output 30000

    #  load-module module-null-sink sink_name=rtp
    #  load-module module-rtp-send source=rtp.monitor destination_ip=192.168.1.101
    #'';
  };

  # PulseAudio needs a restart after resume to fix Bluetooth audio
  #powerManagement.resumeCommands = "killall pulseaudio";

  # Suspend when lid closed, handled by KDE?
  #services.logind.lidSwitch = "suspend";

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    fira-code
    fira-code-symbols
  ];

  # Steam & co. needs this
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "dvorak";

  # Use libinput
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  #services.xserver.displayManager.sddm.enable = true;
  #services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.windowManager.herbstluftwm.enable = true;

  # Enable GNOME 3
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  # Annoying hack to stop GDM from using PulseAudio
  # (and thus capturing Bluetooth A2DP audio profiles)
  # TODO: store gdm-pulse-client.conf in the Nix store,
  # currently this requires a manual step of copying it
  # from this git repo into /etc
  systemd.tmpfiles.rules = [
    "d /run/gdm/.config 0700 gdm gdm - -"

    "d /run/gdm/.config/pulse 0700 gdm gdm - -"
    "C /run/gdm/.config/pulse/default.pa 0600 gdm gdm - /etc/gdm-pulse-default.pa"

    # TODO: this file might not be needed
    "C /run/gdm/.config/pulse/client.conf 0600 gdm gdm - /etc/gdm-pulse-client.conf"

    # TODO: this systemd socket activation hack might not be needed
    "d /run/gdm/.config/systemd 0700 gdm gdm - -"
    "d /run/gdm/.config/systemd/user 0700 gdm gdm - -"
    "L /run/gdm/.config/systemd/user/pulseaudio.socket 0600 gdm gdm - /dev/null"
  ];

  # Adjust display color temperature during nighttime
  #services.redshift.enable = true;
  #services.redshift.provider = "manual";
  #services.redshift.latitude = "60";
  #services.redshift.longitude = "0";
  #services.redshift.temperature.night = 1900;

  services.upower.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.gutenprintBin
    pkgs.hplip
    #pkgs.samsungUnifiedLinuxDriver
    #pkgs.splix
  ];

  # Nice bootup screen
  boot.plymouth.enable = true;

  # Android stuff
  programs.adb.enable = true;
  programs.java.enable = true;
  #users.extraUsers.${user}.extraGroups = ["adbusers"];

  # Steam controller udev rules
  # TODO: maybe move this elsewhere
  services.udev = {
    extraRules = ''
      SUBSYSTEM=="serio", DRIVERS=="psmouse", ATTRS{press_to_select}="1", ATTRS{sensitivity}="122" ATTRS{drift_time}="30"

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

      # Enable USB tethering when plugging in my phone
      ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="107e", ACTION=="add", RUN+="${pkgs.systemd}/bin/systemctl --no-block start tether.service"
    '';
  };

  systemd.services.tether = {
    environment = {
      ADB = "${pkgs.androidsdk}/bin/adb";
    };
    serviceConfig = {
      User = user;
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash /etc/nixos/home/${user}/bin/tether.sh";
    };
  };
}
