{ config, pkgs, lib, user, ... }:

{
  imports =
    [
      ../../client.nix
    ];

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/8f6522ac-418b-43a2-b006-a61ff4113568";
      preLVM = true;
      allowDiscards = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.displayManager.gdm.wayland = false;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  services.buildkite-agents.test1 = {
    enable = true;
    tokenPath = "/var/lib/buildkite-agent-test1/token";
    privateSshKeyPath = "/var/lib/buildkite-agent-test1/id_rsa_buildkite";
    tags = { queue = "tamarillo"; };
    extraConfig = "priority=3";
  };

  services.buildkite-agents.test2 = {
    enable = true;
    tokenPath = "/var/lib/buildkite-agent-test2/token";
    privateSshKeyPath = "/var/lib/buildkite-agent-test2/id_rsa_buildkite";
    tags = { queue = "tamarillo"; };
    extraConfig = "priority=3";
  };
}
