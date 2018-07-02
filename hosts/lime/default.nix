{ config, pkgs, ... }:

{
  imports =
    [
      ../../client.nix
    ];

  # Use the most recent kernel in hopes of eventual better S0i3 support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Fix S3 suspend on X1C6 by patching DSDT tables.
  # How to obtain your own acpi_override file:
  # https://delta-xi.net/#056
  boot.initrd.prepend = [ "/etc/nixos/hosts/lime/acpi_override" ];
  boot.kernelParams = [
    "acpi.ec_no_wakeup=1"
    "mem_sleep_default=deep"
  ];

  # Fixes unresponsive TrackPoint
  boot.extraModprobeConfig = ''
    options psmouse proto=bare
  '';

  # Tweak TrackPoint sensitivity and speed
  hardware.trackpoint.enable = true;
  hardware.trackpoint.sensitivity = 255;
  hardware.trackpoint.speed = 150;

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
}
