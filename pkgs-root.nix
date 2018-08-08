{ config, pkgs, ... }: 

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in {
  nixpkgs.config.packageOverrides = {
    unstable = import unstableTarball {
      config = config.nixpkgs.config;
    };
  };

  environment.systemPackages = with pkgs; [
    # Misc CLI tools
    (import ./fhs)

    # Key generation
    openssl

    # Debugging power stuff
    powertop

    # Network debugging tools
    tcpdump
    iperf

    # Audio
    pulseaudio-dlna

    # Windows crap
    ntfs3g

    # GUI stuff
    unstable.vscode
    xsel # needed by vscode vim plugin
  ];
}
