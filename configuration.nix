# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

let
  hostname = import ./hostname.nix;
  user = "rasse";
in {
  # Make user and hostname available to included modules
  _module.args.user = user;
  _module.args.hostname = hostname;

  imports =
    [
      ("/etc/nixos/hosts/" + hostname + "/hardware-configuration.nix")
      ./common.nix
      ("/etc/nixos/hosts/" + hostname)
    ];
}
