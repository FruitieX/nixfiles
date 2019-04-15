{ config, pkgs, lib, user, ... }:

{
  imports =
    [
      ../../client.nix
    ];

  # Disable USB autosuspend, as otherwise my mouse & keyboard shut off after 2 sec inactivity
  boot.kernelParams = ["usbcore.autosuspend=-1"];

  # Update Intel CPU microcode
  hardware.cpu.intel.updateMicrocode = true;

  # NoVideo doesn't support Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.wayland = false;

  # ...And also not the latest kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  virtualisation.virtualbox.host.enable = true;

  # PostgreSQL server for development purposes.
  # Accepts connections on 127.0.0.1 with "postgres" user
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_10;
    authentication = lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };
}
