{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../../client.nix
      ./cpu-throttling-bug.nix
    ];

  # Use the most recent kernel in hopes of eventual better S0i3 support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Fix S3 suspend on X1C6 by patching DSDT tables.
  # How to obtain your own acpi_override file:
  # https://delta-xi.net/#056
  # NOTE: This has been fixed by a recent firmware update by Lenovo.
  # Enable "Linux" sleep mode in BIOS for fix.
  # boot.initrd.prepend = [ "/etc/nixos/hosts/lime/acpi_override" ];
  boot.kernelParams = [
    #"acpi.ec_no_wakeup=1"
    #"mem_sleep_default=deep"
    "psmouse.synaptics_intertouch=1"
  ];

  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  services.tlp.enable = true;

  #boot.extraModprobeConfig = ''
  #  options psmouse proto=bare
  #'';

  powerManagement.resumeCommands = ''
    echo "Reconnecting TrackPoint"
    echo -n none > /sys/devices/platform/i8042/serio1/drvctl
    sleep 1
    echo -n reconnect > /sys/devices/platform/i8042/serio1/drvctl
  '';

  hardware.trackpoint = {
    enable = true;
    sensitivity = 255;
    speed = 255;
    device = "TPPS/2 Elan TrackPoint";
    #device = "PS/2 Generic Mouse";
  };

  # Disable governor set in hardware-configuration.nix,
  # required when services.tlp.enable is true:
  powerManagement.cpuFreqGovernor =
    lib.mkIf config.services.tlp.enable (lib.mkForce null);

  hardware.cpu.intel.updateMicrocode = true;

  # Auto-mount encrypted LUKS home partition on login.
  # Partition can be created during setup with:
  #
  #   # Note! Password must match with user's password:
  #   cryptsetup luksFormat /dev/<some-partition>
  #   cryptsetup open /dev/<some-partition> home
  #   mkfs.ext4 -L home /dev/mapper/home
  #   mount /dev/mapper/home /home/<username>
  #   chown -R <username>:users /home/<username>

  users.extraUsers.rasse.cryptHomeLuks = "/dev/nvme0n1p8";
  security.pam.mount.enable = true;

  # Virtualisation
  virtualisation.virtualbox.host.enable = true;
  # users.extraUsers.rasse.extraGroups = ["vboxusers"];
  # virtualisation.docker.enable = true;
  # users.extraUsers.rasse.extraGroups = ["docker"];

  # Renoise
  environment.systemPackages = with pkgs; [
    (pkgs.renoise.override {
      releasePath = "/home/rasse/nixfiles/ignore/rns_3_1_1_linux_x86_64.tar.gz";
    })
  ];
}
