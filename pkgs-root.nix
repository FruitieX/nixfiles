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

    # Dev stuff
    unstable.android-studio

    # Key generation
    openssl

    # Debugging power stuff
    powertop

    # Audio
    pulseaudio-dlna

    # qdbus lives in qttools
    unstable.qt5.qttools

    # Windows crap
    wine
    ntfs3g

    # GUI stuff
    unstable.ark
    unstable.firefox
    unstable.google-chrome
    unstable.alacritty
    unstable.xorg.xmodmap
    unstable.gimp
    unstable.rawtherapee
    unstable.nitrogen
    unstable.synergy
    unstable.okular
    unstable.filezilla
    unstable.kdeApplications.kio-extras               # MTP support for Dolphin
    unstable.steam
    #(pkgs.renoise.override {
      #releasePath = "/etc/nixos/renoise/rns_3_1_1_linux_x86_64.tar.gz";
    #})
    unstable.libreoffice-fresh
  ];
}
