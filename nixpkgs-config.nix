{
  # Allow non-free licenses
  allowUnfree = true;

  # Android SDK license
  android_sdk.accept_license = true;

  # Inspired by https://github.com/GeoscienceAustralia/NixOS-Machines/blob/master/nixpkgs-config.nix
  packageOverrides = super: let
    self = super.pkgs;
  in
    with self; rec {
      # Declarative config

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

      # Channel based

      # unstable package set, install by running:
      # sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable
      # unstable = import <unstable> {
      #   config = self.config;
      # };

      # unstable-small package set, install by running:
      # sudo nix-channel --add https://nixos.org/channels/nixos-unstable-small unstable-small
      # unstable-small = import <unstable-small> {
      #   config = self.config;
      # };

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

      updatePrefetch = import (
        master.fetchFromGitHub {
          owner = "justinwoo";
          repo = "update-prefetch";
          rev = "ffcf4e287bce46615056cf5466176dd70e5fb1bc";
          sha256 = "0g7c4p8w738s0rnn1pbr39g0qv0jp6rwbdzimmb28g9g82mnc5v6";
        }
      ) { pkgs = master; };

      nixpkgsFmt = import (
        pkgs.fetchFromGitHub {
          owner = "justinwoo";
          repo = "my-nixpkgs-fmt";
          rev = "4496a67817e3dc2f40c60db971a1d503b353415c";
          sha256 = "1z9k1jlbqlfb2wgqlvpqvlrxwpz3j9syinx6f8705z34q1yjnxnb";
        }
      ) {};

      systemToolsEnv = with super; buildEnv {
        name = "systemToolsEnv";
        paths = [
          # Global CLI tools
          awscli
          bc
          # binutils # contains eg readelf
          dos2unix
          gnupg
          git
          tig
          jq
          pass
          procps
          openssl
          ripgrep
          tmux
          unzip
          zip
	  srm
	  file
	  man
	  master.starship

          # Networking
          dnsutils
          curlie
          iperf
          openssh
          sshfs
          tcpdump
          wget
	  socat

          # Editors
          (unstable.neovim.override (import ./configs/neovim-config.nix { inherit pkgs; }))

          # System utils
          cryptsetup
          cpufrequtils
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
          nix-direnv
          nox
          nix-zsh-completions
          nix-prefetch-git
          updatePrefetch
          nixpkgsFmt

          # Development
          # unstable-small.nodejs-11_x
          # (unstable-small.yarn.override { nodejs = unstable-small.nodejs-11_x; })
          postgresql_11
	  gnumake
	  docker-compose
	  gcc
	  openssl
	  openssl.dev
	  pkg-config
        ];
      };

      otherOsEnv = with super; buildEnv {
        name = "otherOsEnv";
        paths = [
          # (unstable.fish.override (import ./configs/fish-config.nix { inherit pkgs; }))
          # (unstable.tmux.override (import ./configs/tmux-config.nix { inherit pkgs; }))
        ];
      };

      desktopToolsEnv = with super; buildEnv {
        name = "desktopToolsEnv";
        paths = [
          # Browsers
          chromium
          unstable-small.firefox-bin
          unstable-small.google-chrome

          # Development
          (
            master.vscode-with-extensions.override {
              vscodeExtensions = master.vscode-utils.extensionsFromVscodeMarketplace (import ./configs/vscode-extensions.nix).extensions;
            }
          )
          xsel # needed by vscode vim plugin
          dbeaver
          wireshark-qt

          # Windows
          #unstable.wine
          #unstable.winetricks

          # Misc GUI programs
          unstable.alacritty
          unstable-small.barrier
          unstable.xorg.xmodmap
	  unstable.pavucontrol
	  unstable.xorg.xev

          # Misc
          unstable.noto-fonts-emoji
          gparted
        ];
      };
    };
}
