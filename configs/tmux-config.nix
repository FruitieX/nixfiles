{ pkgs, ... }:

{
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
}