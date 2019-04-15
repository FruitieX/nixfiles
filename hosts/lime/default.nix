{ config, pkgs, lib, user, ... }:

{
  # NOTE:
  # X1C6 users should run the following firmware update utilities using Windows
  # in this order before proceeding:
  # - BIOS Update Utility (adds S3 suspend mode)
  # - Synaptics Touchpad Firmware (prevents unresponsive touchpad/trackpoint
  #   after the following update...)
  # - TrackPoint Firmware Update Utility (fixes TrackPoint drift issues)
  #
  # Afterwards, make sure to enable "Linux sleep mode" in the BIOS settings to
  # fix suspend issues on Linux

  imports =
    [
      ../../client.nix
      ./cpu-throttling-bug.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Update Intel CPU microcode
  hardware.cpu.intel.updateMicrocode = true;

  # Web development is resource intensive, download more RAM
  zramSwap.enable = true;
  zramSwap.memoryPercent = 10;
  boot.kernel.sysctl = { "vm.swappiness" = 80; };
  services.earlyoom.enable = true;

  # Disable governor set in hardware-configuration.nix,
  # required when services.tlp.enable is true:
  powerManagement.cpuFreqGovernor =
    lib.mkIf config.services.tlp.enable (lib.mkForce null);
  services.tlp.enable = true;

  # Use IMPS protocol for TrackPoint. Fixes unresponsive TrackPoint after
  # resume, and makes the TrackPoint a lot smoother at least this machine.
  boot.extraModprobeConfig = ''
    options psmouse proto=imps
  '';

  # GPU video decoding support
  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];

  # Auto-mount encrypted LUKS home partition on login.
  # Partition can be created during setup with:
  #
  #   # Note! Password must match with user's password:
  #   cryptsetup luksFormat /dev/<some-partition>
  #   cryptsetup open /dev/<some-partition> home
  #   mkfs.ext4 -L home /dev/mapper/home
  #   mount /dev/mapper/home /home/<username>
  #   chown -R <username>:users /home/<username>
  users.extraUsers.${user}.cryptHomeLuks = "/dev/nvme0n1p8";
  security.pam.mount.enable = true;
  #security.pam.services.${user}.pamMount = true;

  # Virtualisation

  # Enable VirtualBox with proprietary extensions pack
  # NOTE: this causes VirtualBox to be compiled from source,
  # remove the enableExtensionPack option if this is undesirable
  virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  # users.extraUsers.${user}.extraGroups = ["vboxusers"];
  # virtualisation.docker.enable = true;
  #users.extraUsers.${user}.extraGroups = ["docker"];

  # Renoise
  #environment.systemPackages = with pkgs; [
    #(pkgs.renoise.override {
      #releasePath = "/home/${user}/nixfiles/ignore/rns_3_1_1_linux_x86_64.tar.gz";
    #})
  #];

  # Fix a certain wi-fi portal login
  networking.extraHosts = "132.171.104.123 securelogin.arubanetworks.com";

  # PostgreSQL server for development purposes.
  # Accepts connections on 127.0.0.1 with "postgres" user
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_10;
    authentication = lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };
}
