{ config, pkgs, lib, user, ... }:

{
  imports =
    [
      ../../client.nix
    ];

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/8f6522ac-418b-43a2-b006-a61ff4113568";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.displayManager.gdm.wayland = false;

  # virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  services.buildkite-agent.enable = true;
  services.buildkite-agent.tokenPath = "/var/lib/buildkite-agent/token";
  services.buildkite-agent.openssh.privateKeyPath = "/var/lib/buildkite-agent/id_rsa_buildkite";
  services.buildkite-agent.openssh.publicKeyPath = "/var/lib/buildkite-agent/id_rsa_buildkite.pub";
}
