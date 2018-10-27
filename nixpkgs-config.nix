{
  # Allow non-free licenses
  allowUnfree = true;

  # Inspired by https://github.com/GeoscienceAustralia/NixOS-Machines/blob/master/nixpkgs-config.nix
  packageOverrides = super: let self = super.pkgs; in with self; rec {
    # Unstable package set
    unstable = import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz) {
      config = {
        allowUnfree = true;
      };
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
        httpie
        iperf
        tcpdump
        sshfs
        wget

        # Editors
        unstable.neovim
        vim

        # System utils
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
      ];
    };

    desktopToolsEnv = with super; buildEnv {
      name = "desktopToolsEnv";
      paths = [
        # Browsers
        unstable.chromium
        unstable.firefox
        unstable.google-chrome

        # Development
        unstable.vscode
        xsel # needed by vscode vim plugin

        # Windows
        unstable.wine
        unstable.winetricks

        # Media
        unstable.gimp
        unstable.rawtherapee
        unstable.spotify
        unstable.vlc

        # Misc GUI programs
        unstable.alacritty
        unstable.filezilla
        unstable.libreoffice
        unstable.synergy
        unstable.steam
        unstable.xorg.xmodmap

        # Misc
        unstable.noto-fonts-emoji
      ];
    };
  };
}
