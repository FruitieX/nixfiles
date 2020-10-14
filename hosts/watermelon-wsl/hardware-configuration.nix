# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, user, ... }:

let
  defaultUser = user;
  syschdemd = import ./syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/minimal.nix>
  ];

  # WSL is closer to a container than anything else
  boot.isContainer = true;

  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;

  networking.dhcpcd.enable = false;

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  # Described as "it should not be overwritten" in NixOS documentation,
  # but it's on /run per default and WSL mounts /run as a tmpfs, hence
  # hiding the wrappers.
  security.wrapperDir = "/wrappers";

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;

  nix.maxJobs = lib.mkDefault 8;
}