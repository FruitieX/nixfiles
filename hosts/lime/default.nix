{ config, pkgs, lib, user, ... }:

{
  imports =
    [
      ../../client.nix
      ./cpu-throttling-bug.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  services.tlp.enable = true;

  boot.extraModprobeConfig = ''
    options psmouse proto=imps
  '';

  # Disable governor set in hardware-configuration.nix,
  # required when services.tlp.enable is true:
  powerManagement.cpuFreqGovernor =
    lib.mkIf config.services.tlp.enable (lib.mkForce null);

  hardware.cpu.intel.updateMicrocode = true;

  # Auto-mount encrypted LUKS home partition on login.
  # Partition can be created during setup with:
  #
  #   # Note! Password must match with user's password:
  #   cryptsetup luksFormat /dev/<some-partition>
  #   cryptsetup open /dev/<some-partition> home
  #   mkfs.ext4 -L home /dev/mapper/home
  #   mount /dev/mapper/home /home/<username>
  #   chown -R <username>:users /home/<username>
  users.extraUsers.${user}.cryptHomeLuks = "/dev/nvme0n1p8";
  security.pam.mount.enable = true;

  # Virtualisation
  virtualisation.virtualbox.host.enable = true;
  # users.extraUsers.${user}.extraGroups = ["vboxusers"];
  # virtualisation.docker.enable = true;
  #users.extraUsers.${user}.extraGroups = ["docker"];

  # Renoise
  #environment.systemPackages = with pkgs; [
    #(pkgs.renoise.override {
      #releasePath = "/home/${user}/nixfiles/ignore/rns_3_1_1_linux_x86_64.tar.gz";
    #})
  #];

  # Fix a certain wi-fi portal login
  networking.extraHosts = "132.171.104.123 securelogin.arubanetworks.com";

  # PostgreSQL server for development purposes.
  # Accepts connections on 127.0.0.1 with "postgres" user
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql100;
    authentication = lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };
}
