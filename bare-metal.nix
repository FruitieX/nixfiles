# This config only applies when installing NixOS on bare metal

{ config, pkgs, lib, user, hostname, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  # boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

  networking.networkmanager.enable = true;
}
