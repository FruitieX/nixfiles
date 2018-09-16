{ pkgs, ... }: with pkgs; [
  # Misc CLI tools
  (import ./fhs pkgs)

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
  unstable.spotify
  xsel # needed by vscode vim plugin
]
