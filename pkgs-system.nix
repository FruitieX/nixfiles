# These packages are only available in the system environment

{ pkgs, ... }: with pkgs; [
  # Misc CLI tools
  (import ./fhs pkgs)

  # Debugging power stuff
  powertop

  # Virtualisation
  #docker
  #docker_compose

  # Network debugging tools
  tcpdump
  iperf

  # Audio
  pulseaudio-dlna

  # Windows crap
  ntfs3g

  # NixOS stuff
  nox
  nix-zsh-completions

  direnv
]
