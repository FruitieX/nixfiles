# This file contains configs that are common for all of my hosts

{ config, pkgs, lib, user, hostname, ... }:

{
  nixpkgs.config = import ./nixpkgs-config.nix;

  # System packages are common to all hosts
  environment.systemPackages = with pkgs; [
    systemToolsEnv
    (import ./fhs pkgs)
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Power management
  powerManagement.cpuFreqGovernor = "ondemand";
  powerManagement.powertop.enable = true;

  # Kernel same-page merging
  hardware.enableKSM = true;

  # Define a user account. Don't forget to change your password.
  users.extraUsers = {
    ${user} = {
      password = "change-me";
      isNormalUser = true;
      extraGroups = [ "wheel" "adbusers" "vboxusers" "audio" "sway" "docker" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxHyNeiwAzZoExz8iOWkxYmb/3xsN9QVwp/R0/SRUZlFQRPoXk4Ncwkt/U8aiSpm0XmrG1WWGYO9lf5UzAPX8LyHOfjaOyvCTok7RhyMSYZ1cBOJsEQ8MfMRKqjZ0vBaLjRDZoFBERT+/VBfazjTUB1Fv8dGHS8PLvdhMly2VinsSGTc/tApdigP61SJeLmo7NoDavBqTKHx1efJRAw4dRKilhl8fOvAsBCuOn9UzBdZAYX4WTpHvlZGFnkRvLteeAmHGuFPUq8ofc3X4HZfukIz1/l5Ya8l5srHAQEsSpKGcG7EuRHBz+cwEulfjDKlVyFK1Jx7UwJHFGKENtFbST rasse" ];
    };
  };

  # Fish shell configs
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Launch in tmux session if we're not already in one
      if not test $TMUX
        exec tmux new-session -t 0 \; set-option destroy-unattached
      end

      # Fish vi keybindings with jj mapped to normal mode
      fish_vi_key_bindings
      bind -M insert -m default jj force-repaint
    '';

    promptInit = ''
      set normal (set_color normal)
      set magenta (set_color magenta)
      set yellow (set_color yellow)
      set green (set_color green)
      set red (set_color red)
      set gray (set_color -o black)

      # Fish git prompt
      set __fish_git_prompt_showdirtystate 'yes'
      set __fish_git_prompt_showstashstate 'yes'
      set __fish_git_prompt_showuntrackedfiles 'yes'
      set __fish_git_prompt_showupstream 'yes'
      set __fish_git_prompt_color_branch green
      set __fish_git_prompt_color_dirtystate blue
      set __fish_git_prompt_color_upstream_ahead yellow
      set __fish_git_prompt_color_upstream_behind yellow

      # Status Chars
      set __fish_git_prompt_char_dirtystate '*'
      set __fish_git_prompt_char_stagedstate '+'
      set __fish_git_prompt_char_untrackedfiles 'u'
      set __fish_git_prompt_char_stashstate 's'
      set __fish_git_prompt_char_upstream_ahead '>'
      set __fish_git_prompt_char_upstream_behind '<'
      set __fish_git_prompt_char_upstream_prefix ""

      function fish_prompt
        set last_status $status

        set_color $fish_color_cwd
        printf '%s' (prompt_pwd)
        set_color normal

        printf '%s ' (__fish_git_prompt)

        set_color normal
      end
    '';

    # Git aliases, adapted from https://github.com/sorin-ionescu/prezto/blob/master/modules/git/alias.zsh
    shellAliases = {
      g = "git";

      # Branch (b)
      gb = "git branch";
      gbc = "git checkout -b";
      gbd = "git branch --delete";

      # Commit (c)
      gc = "git commit --verbose";
      gca = "git commit --verbose --all";
      gcm = "git commit --message";
      gco = "git checkout";
      gcf = "git commit --amend --reuse-message HEAD";
      gcp = "git cherry-pick --ff";

      # Fetch (f)
      gf = "git fetch";
      gfc = "git clone";
      gfm = "git pull";
      gfr = "git pull --rebase";
      gl = "gfm";

      # Index (i)
      gia = "git add";
      giA = "git add --patch";
      gir = "git reset";

      # Log (l)
      gls = "git log --topo-order --stat --pretty=format:\"%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B\"";
      glg = "git log --topo-order --all --graph --pretty=format:\"%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n\"";

      # Push (p)
      gp = "git push";
      gpf = "git push --force-with-lease";
      gpF = "git push --force";
      gpc = "git push --set-upstream origin (git symbolic-ref HEAD 2> /dev/null | sed s-refs/heads/--)";

      # Rebase (r)
      gr = "git rebase";
      gra = "git rebase --abort";
      grc = "git rebase --continue";
      gri = "git rebase --interactive";
      grs = "git rebase --skip";

      # Stash (s)
      gs = "git stash";
      gsp = "git stash pop";

      # Working Copy (w)
      gws = "git status --short";
      gwd = "git diff --no-ext-diff";
    };
  };

  # Networking
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts = [ 1234 3000 ];

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # services.fwupd.enable = true;

  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    passwordAuthentication = lib.mkDefault false;
  };

  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    scrapeConfigs = lib.mkDefault [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:9100" ];
            labels.alias = hostname;
          }
        ];
      }
    ];
    exporters.node = {
      enable = true;
      enabledCollectors = [
        "logind"
        "systemd"
      ];
    };
  };
  services.grafana = {
    enable = true;
    port = 4000;
  };

  environment.variables = {
    ZPREZTO = [ "${pkgs.zsh-prezto}" ];
    NIXOS_CONFIG = [ "/home/${user}/nixfiles" ];

    # enable smooth scrolling in firefox
    MOZ_USE_XINPUT2 = [ "1" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

  system.autoUpgrade.enable = true;

  # Symlink dotfiles
  system.activationScripts.dotfiles = import ./scripts/symlink.nix {
    inherit user;
    source = "/home/${user}/nixfiles/home";
    target = "/home";
  };
}
