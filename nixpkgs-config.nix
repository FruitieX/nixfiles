{
  # Allow non-free licenses
  allowUnfree = true;

  # Android SDK license
  android_sdk.accept_license = true;

  # Inspired by https://github.com/GeoscienceAustralia/NixOS-Machines/blob/master/nixpkgs-config.nix
  packageOverrides = super: let self = super.pkgs; in with self; rec {
    # Declarative config

    # Unstable package set
    # View last updated time at: https://howoldis.herokuapp.com
    # unstable = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) {
    #   config = self.config;
    # };

    # Unstable-small package set
    # Contains more recent packages, but larger chance of having to build from source.
    # This is fine for binary packages though, which build fast anyway.
    # unstable-small = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable-small.tar.gz) {
    #   config = self.config;
    # };

    # Channel based

    # unstable package set, install by running:
    # sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable
    unstable = import <unstable> {
      config = self.config;
    };

    # unstable-small package set, install by running:
    # sudo nix-channel --add https://nixos.org/channels/nixos-unstable-small unstable-small
    unstable-small = import <unstable-small> {
      config = self.config;
    };

    # https://vaibhavsagar.com/blog/2018/05/27/quick-easy-nixpkgs-pinning/
    #master = import (fetchFromGitHub {
    #  owner = "nixos";
    #  repo = "nixpkgs";
    #  rev = "master";
    #}) {
    #  config = self.config;
    #};
    master = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz) {
      config = self.config;
    };

    systemToolsEnv = with super; buildEnv {
      name = "systemToolsEnv";
      paths = [
        # Global CLI tools
        awscli
        bc
        binutils # contains eg readelf
        dos2unix
        gnupg
        git
        jq
        pass
        openssl
        ripgrep
        tmux
        unzip
        zip

        # Networking
        dnsutils
        httpie
        iperf
        openssh
        sshfs
        tcpdump
        wget

        # Editors
        unstable.neovim
        vim

        # System utils
        cryptsetup
        htop
        lm_sensors
        ncdu
        ntfs3g
        pciutils
        psmisc
        powertop
        strace
        unstable.s-tui
        unstable.stress
        usbutils

        # Nix specific
        direnv
        nox
        nix-zsh-completions

        # Development
        unstable-small.nodejs-10_x
        postgresql100
      ];
    };

    desktopToolsEnv = with super; buildEnv {
      name = "desktopToolsEnv";
      paths = [
        # Browsers
        unstable.chromium
        unstable-small.firefox-bin
        unstable-small.google-chrome

        # Development
        master.vscode
        xsel # needed by vscode vim plugin

        # Windows
        unstable.wine
        unstable.winetricks

        # Misc GUI programs
        unstable.alacritty
        unstable-small.synergy
        unstable.xorg.xmodmap

        # Misc
        unstable.noto-fonts-emoji
      ];
    };
  };
}
