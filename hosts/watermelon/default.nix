{ config, pkgs, lib, user, ... }:

{
  imports =
    [
      ../../client.nix
    ];

  # Disable USB autosuspend, as otherwise my mouse & keyboard shut off after 2 sec inactivity
  # boot.kernelParams = ["usbcore.autosuspend=-1"];

  # Update Intel CPU microcode
  # hardware.cpu.intel.updateMicrocode = true;

  # NoVideo doesn't support Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.wayland = false;

  # ...And also not the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # wifi & bluetooth
  # boot.kernelModules = [ "iwlwifi" ];
  # hardware.enableAllFirmware = true;
  hardware.firmware = [ pkgs.master.firmwareLinuxNonfree ];

  # virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  users.extraUsers.code = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxHyNeiwAzZoExz8iOWkxYmb/3xsN9QVwp/R0/SRUZlFQRPoXk4Ncwkt/U8aiSpm0XmrG1WWGYO9lf5UzAPX8LyHOfjaOyvCTok7RhyMSYZ1cBOJsEQ8MfMRKqjZ0vBaLjRDZoFBERT+/VBfazjTUB1Fv8dGHS8PLvdhMly2VinsSGTc/tApdigP61SJeLmo7NoDavBqTKHx1efJRAw4dRKilhl8fOvAsBCuOn9UzBdZAYX4WTpHvlZGFnkRvLteeAmHGuFPUq8ofc3X4HZfukIz1/l5Ya8l5srHAQEsSpKGcG7EuRHBz+cwEulfjDKlVyFK1Jx7UwJHFGKENtFbST rasse" ];
  };

  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    authentication = lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };
}
