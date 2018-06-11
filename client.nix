{ config, pkgs, ... }:

{
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
    extraClientConf = ''
      set-port-latency-offset bluez_card.B8_D5_0B_E5_11_22 speaker-output 30000
    '';
  };

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

  # Adjust display color temperature during nighttime
  services.redshift.enable = true;
  services.redshift.provider = "geoclue2";
  services.redshift.temperature.night = 1900;

  # Android stuff
  programs.adb.enable = true;
  programs.java.enable = true;
}
