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

  programs.tmux = {
    enable = true;

    newSession = true;
    aggressiveResize = true;
    secureSocket = true;
    keyMode = "vi";
    shortcut = "a";
    terminal = "screen-256color";
    baseIndex = 1;
    escapeTime = 0;

    extraTmuxConf = ''
      # tmux plugins
      run-shell ${pkgs.tmuxPlugins.sensible.rtp}
      run-shell ${pkgs.tmuxPlugins.yank.rtp}
      run-shell ${pkgs.tmuxPlugins.copycat.rtp}

      # automatically destroy session after all clients detach
      set-option destroy-unattached

      # mouse support
      set -g mouse on
      bind -n MouseDrag1Status swap-window -t=

      # split panes with C-v (vertical split), C-s (horizontal split)
      bind s split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"

      # create new windows (or "tabs") with C-c
      bind c new-window -c "#{pane_current_path}"

      # focus panes with C-hjkl
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # resize panes with C-a C-hjkl
      bind C-h resize-pane -L 8
      bind C-j resize-pane -D 8
      bind C-k resize-pane -U 8
      bind C-l resize-pane -R 8

      # move panes with C-a C-HJKL
      bind H swap-pane -U
      bind L swap-pane -D
      bind J swap-pane -D
      bind K swap-pane -U

      # move pane to another window with C-m
      bind C-m break-pane
      bind m command-prompt -p "move pane to:"  "move-pane -t ':%%'"

      # clear screen with C-a C-c
      bind C-c send-keys 'C-l'

      # vi-style controls for copy mode
      bind Escape copy-mode
      bind -Tvi-copy 'v' send -X begin-selection
      bind -Tvi-copy 'y' send -X copy-selection

      # activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off
      set -g visual-bell off

      # appearance settings
      set -g pane-border-fg "#555555"
      set -g pane-border-bg default
      set -g pane-active-border-fg "#ffffff"
      set -g pane-active-border-bg default

      set -g status-bg default
      set -g status-fg "#ffffff"

      set -g status on
      set -g status-interval 1
      set -g status-justify "left"
      set -g status-left-length 80
      set -g status-right-length 130
      set -g status-left ""
      set -g status-right "#h"
      set -g status-position top

      setw -g window-status-format "#[bg=#555555, fg=#ffffff, noreverse] #I #W "
      setw -g window-status-current-format "#[bg=#ffffff, fg=#000000, noreverse] #I #W "
      setw -g window-status-separator " "
      setw -g window-status-bell-bg default
      setw -g window-status-bell-fg red
      setw -g window-status-bell-attr none
      setw -g window-status-activity-bg default
      setw -g window-status-activity-fg cyan
      setw -g window-status-activity-attr bold
    '';
  };

  environment.variables = {
    NIXOS_CONFIG = [ "/home/${user}/nixfiles" ];
    #NIXPKGS_CONFIG = [ "/home/${user}/nixfiles/nixpkgs-config.nix" ];

    # enable smooth scrolling in firefox
    MOZ_USE_XINPUT2 = [ "1" ];
  };

  environment.extraInit = ''
    # LS colors
    eval `${pkgs.coreutils}/bin/dircolors "${./dircolors.256dark}"`
  '';

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
