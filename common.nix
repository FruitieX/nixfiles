# This file contains configs that are common for all of my hosts

{ config, pkgs, lib, user, hostname, ... }:

{
  nixpkgs.config = import ./nixpkgs-config.nix;

  # System packages are common to all hosts
  environment.systemPackages = with pkgs; [
    systemToolsEnv
  ];

  # Kernel same-page merging
  hardware.ksm.enable = true;

  hardware.enableRedistributableFirmware = true;

  # Define a user account. Don't forget to change your password.
  users.extraUsers = {
    ${user} = {
      password = "change-me";
      isNormalUser = true;
      extraGroups = [ "wheel" "adbusers" "vboxusers" "audio" "sway" "docker" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxHyNeiwAzZoExz8iOWkxYmb/3xsN9QVwp/R0/SRUZlFQRPoXk4Ncwkt/U8aiSpm0XmrG1WWGYO9lf5UzAPX8LyHOfjaOyvCTok7RhyMSYZ1cBOJsEQ8MfMRKqjZ0vBaLjRDZoFBERT+/VBfazjTUB1Fv8dGHS8PLvdhMly2VinsSGTc/tApdigP61SJeLmo7NoDavBqTKHx1efJRAw4dRKilhl8fOvAsBCuOn9UzBdZAYX4WTpHvlZGFnkRvLteeAmHGuFPUq8ofc3X4HZfukIz1/l5Ya8l5srHAQEsSpKGcG7EuRHBz+cwEulfjDKlVyFK1Jx7UwJHFGKENtFbST rasse" ];
    };
  };

  environment.variables = {
    NIXOS_CONFIG = [ "/home/${user}/nixfiles/configuration.nix" ];
    #NIXPKGS_CONFIG = [ "/home/${user}/nixfiles/nixpkgs-config.nix" ];

    # enable smooth scrolling in firefox
    MOZ_USE_XINPUT2 = [ "1" ];
  };

  programs.fish = (import ./configs/fish-config.nix { inherit pkgs; });
  programs.zsh = (import ./configs/zsh-config.nix { inherit pkgs; });
  programs.tmux = (import ./configs/tmux-config.nix { inherit pkgs; });

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  # Networking
  networking.hostName = hostname;
  networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts = [ 1234 3000 ];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "dvorak";

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # services.fwupd.enable = true;

  # Sync system time with NTP
  services.ntp.enable = true;

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    passwordAuthentication = lib.mkDefault false;
  };

  #services.prometheus = {
  #  enable = true;
  #  globalConfig.scrape_interval = "10s";
  #  scrapeConfigs = lib.mkDefault [
  #    {
  #      job_name = "node";
  #      static_configs = [
  #        {
  #          targets = [ "localhost:9100" ];
  #          labels.alias = hostname;
  #        }
  #      ];
  #    }
  #  ];
  #  exporters.node = {
  #    enable = true;
  #    enabledCollectors = [
  #      "logind"
  #      "systemd"
  #    ];
  #  };
  #};
  #services.grafana = {
  #  enable = true;
  #  port = 4000;
  #};

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  system.autoUpgrade.enable = true;
  system.autoUpgrade.flags = [ "-I" "nixos-config=/home/${user}/nixfiles/configuration.nix" ];

  # increase max number of open file descriptors
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  security.pam.loginLimits = [{
    domain = "*";
    type = "hard";
    item = "nofile";
    value = "1048576";
  }];

  # Symlink dotfiles
  system.activationScripts.dotfiles = import ./scripts/symlink.nix {
    inherit user;
    source = "/home/${user}/nixfiles/home";
    target = "/home";
  };

  # Join the dark side
  system.activationScripts.let-me-run-random-garbage = with pkgs; let loader = "ld-linux-x86-64.so.2"; in ''
    mkdir -p /lib /lib64
    ln -fs ${pkgs.glibc}/lib64/${loader} /lib64/${loader}
    ln -fs ${pkgs.glibc}/lib/${loader} /lib/${loader}
  '';

  environment.extraInit = ''
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/run/current-system/sw/lib"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.stdenv.cc.cc.lib}/lib"
  '';
}
