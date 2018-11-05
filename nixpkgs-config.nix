{
  # Allow non-free licenses
  allowUnfree = true;

  # Inspired by https://github.com/GeoscienceAustralia/NixOS-Machines/blob/master/nixpkgs-config.nix
  packageOverrides = super: let self = super.pkgs; in with self; rec {
    # Unstable package set
    # View last updated time at: https://howoldis.herokuapp.com
    unstable = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) {
      config = self.config;
    };

    # Unstable-small package set
    # Contains more recent packages, but larger chance of having to build from source.
    # This is fine for binary packages though, which build fast anyway.
    unstable-small = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable-small.tar.gz) {
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
        silver-searcher
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
        unstable-small.vscode
        xsel # needed by vscode vim plugin

        # Windows
        unstable.wine
        unstable.winetricks

        # Media
        unstable-small.gimp
        unstable.rawtherapee
        unstable-small.spotify
        unstable.vlc

        # Misc GUI programs
        unstable.alacritty
        unstable.filezilla
        unstable.libreoffice
        unstable.synergy
        unstable-small.steam
        unstable.xorg.xmodmap

        # Misc
        unstable.noto-fonts-emoji
      ];
    };
  };
}
