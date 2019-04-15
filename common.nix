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

  # All my systems have Intel processors at the moment
  hardware.cpu.intel.updateMicrocode = true;

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

      # Git aliases, mostly from https://github.com/sorin-ionescu/prezto/blob/master/modules/git/alias.zsh
      alias g='git'

      # Branch (b)
      alias gb='git branch'
      alias gbc='git checkout -b'
      alias gbd='git branch --delete'

      # Commit (c)
      alias gc='git commit --verbose'
      alias gca='git commit --verbose --all'
      alias gcm='git commit --message'
      alias gco='git checkout'
      alias gcf='git commit --amend --reuse-message HEAD'
      alias gcp='git cherry-pick --ff'

      # Fetch (f)
      alias gf='git fetch'
      alias gfc='git clone'
      alias gfm='git pull'
      alias gfr='git pull --rebase'
      alias gl='gfm'

      # Index (i)
      alias gia='git add'
      alias giA='git add --patch'
      alias gir='git reset'

      # Log (l)
      # alias gl='git log --topo-order --pretty=format:"%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B"'
      alias gls='git log --topo-order --stat --pretty=format:"%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B"'
      # alias gld='git log --topo-order --stat --patch --full-diff --pretty=format:"%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B"'
      # alias glo='git log --topo-order --pretty=format:"%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n"'
      alias glg='git log --topo-order --all --graph --pretty=format:"%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n"'
      # alias glb='git log --topo-order --pretty=format:"%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n"'
      # alias glc='git shortlog --summary --numbered'
      # alias glS='git log --show-signature'

      # Push (p)
      function current_branch
        set ref (git symbolic-ref HEAD 2> /dev/null); or \
        set ref (git rev-parse --short HEAD 2> /dev/null); or return
        echo $ref | sed s-refs/heads/--
      end

      alias gp='git push'
      alias gpf='git push --force-with-lease'
      alias gpF='git push --force'
      alias gpc='git push --set-upstream origin (current_branch)'

      # Rebase (r)
      alias gr='git rebase'
      alias gra='git rebase --abort'
      alias grc='git rebase --continue'
      alias gri='git rebase --interactive'
      alias grs='git rebase --skip'

      # Stash (s)
      alias gs='git stash'
      alias gsp='git stash pop'

      # Working Copy (w)
      alias gws='git status --short'
      alias gwd='git diff --no-ext-diff'
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

  programs.zsh.autosuggestions.enable = true;
  programs.zsh.enableCompletion = true;
  # TODO: find out why this doesn't work.
  # Currently we load zprezto from .zshrc with awkward hacks
  #programs.zsh.interactiveShellInit = with builtins; ''
  #  export ZDOTDIR=${pkgs.zsh-prezto}/
  #  source "$ZDOTDIR/init.zsh"
  #'';

  #environment.shellAliases = {
  #  la="ls -A";
  #};
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

  # TODO: make this clear out ancient kernels so /boot doesn't fill up
  # OR: resize /boot partition on satsuma so this is no longer an issue
  system.autoUpgrade.enable = true;

  # Symlink dotfiles
  system.activationScripts.dotfiles = import ./scripts/symlink.nix {
    inherit user;
    source = "/home/${user}/nixfiles/home";
    target = "/home";
  };
}
