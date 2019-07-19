# This file contains configs that are useful on laptops,
# such as power saving stuff

{ config, pkgs, user, ... }:

{
  # Power management
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  powerManagement.powertop.enable = true;
}
