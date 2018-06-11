# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:

let
  hostname = import ./hostname.nix;
in {
  imports =
    [
      ("/etc/nixos/hosts/" + hostname + "/hardware-configuration.nix")
      ./common.nix
      ./pkgs-root.nix
      ("/etc/nixos/hosts/" + hostname)
    ];

  # Define global packages that are available in all environments
  environment.systemPackages = import ./pkgs-global.nix pkgs;
}
