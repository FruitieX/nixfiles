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
    wget
    git
    htop
    pass
    tmux
    httpie
    jq
    silver-searcher
    vim
    neovim
    bc
    dos2unix
    gcc
    binutils
    automake
    gnumake

    # Dev stuff
    nodejs-9_x
    unstable.android-studio
    androidsdk
    atom
    unstable.yarn
    docker
    docker_compose
    python2
    python3

    # Thesis stuff
    pandoc
    texlive.combined.scheme-full
    python36Packages.pygments

    # System utils
    pciutils
    psmisc

    # NixOS utils
    nox
    nix-zsh-completions

    # GUI stuff
    unstable.firefox
    unstable.google-chrome
    alacritty
    xorg.xmodmap
    unstable.gimp
    nitrogen
    synergy
    okular
    filezilla
    unstable.steam
  ];
}
