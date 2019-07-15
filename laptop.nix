# This file contains configs that are useful on laptops,
# such as power saving stuff

{ config, pkgs, user, ... }:

{
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
    powertop = {
      enable = true;
    };
  };
}