# These packages are available in all environments

{ pkgs, ... }: with pkgs; [
  # Misc CLI tools
  wget
  openssl
  htop
  git
  pass
  gnupg
  tmux
  httpie
  jq
  silver-searcher
  vim
  unstable.neovim
  bc
  dos2unix
  binutils
  sshfs
  ncdu
  unzip
  zip

  # Build stuff
  gnumake
  automake
  gcc

  # System utils
  usbutils

  # Dev stuff
  unstable.nodejs-10_x
  unstable.yarn
  unstable.androidsdk
  python2Full
  python3
  awscli

  # browsers
  unstable.firefox
  unstable.google-chrome
  chromium

  # System utils
  pciutils
  psmisc
  strace

  # TODO: move these to a nix-shell
  # puppeteer trash
  alsaLib
  gtk3
  at_spi2_atk
]
