{ config, pkgs, ... }:

{
  imports =
    [
      ../../bare-metal.nix
      ../../client.nix
    ];
}
