{ pkgs, ... }:

{
  # Fish shell configuration
  enable = true;

  interactiveShellInit = ''
    mkdir -p $HOME/.tmux
    export TMUX_TMPDIR=$HOME/.tmux

    # Launch in tmux session if we're not already in one
    if not test $TMUX
      exec tmux new-session -t 0 \; set-option destroy-unattached
    end

    # Fish vi keybindings with fixed ctrl+f & jj mapped to normal mode
    function fish_user_key_bindings
        for mode in insert default visual
            bind -M $mode \cf forward-char
        end
    end
    fish_vi_key_bindings
    bind -M insert -m default jj force-repaint

    # LS colors
    eval (${pkgs.coreutils}/bin/dircolors "${./dircolors.base16.dark}" | sed "s/LS_COLORS=/set LS_COLORS /")

    alias gpc "git push --set-upstream origin (git symbolic-ref HEAD 2> /dev/null | sed s-refs/heads/--)"

    # Globally installed npm / yarn packages
    export PATH="$HOME/.npm-packages/bin:$HOME/.yarn/bin:$PATH"

    # Locally installed npm / yarn packages
    export PATH="./node_modules/.bin:$PATH"

    # Locally installed pip packages
    export PATH="$HOME/.local/bin:$PATH"

    # Locally installed cargo packages
    export PATH="$HOME/.cargo/bin:$PATH"

    # Suppress direnv logs
    export DIRENV_LOG_FORMAT=""

    # Don't use nano
    export EDITOR="nvim"
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
    set __fish_git_prompt_color_merging red
    set __fish_git_prompt_color_stagedstate green
    set __fish_git_prompt_color_stashstate blue
    set __fish_git_prompt_color_upstream_ahead yellow
    set __fish_git_prompt_color_upstream_behind yellow

    # Status Chars
    set __fish_git_prompt_char_dirtystate '*'
    set __fish_git_prompt_char_stagedstate '+'
    set __fish_git_prompt_char_untrackedfiles 'u'
    set __fish_git_prompt_char_stashstate 's'
    set __fish_git_prompt_char_upstream_ahead '>'
    set __fish_git_prompt_char_upstream_behind '<'
    set __fish_git_prompt_char_upstream_equal ""
    set __fish_git_prompt_char_stateseparator ' '

    function fish_prompt
      set last_status $status

      set_color $fish_color_cwd
      printf '%s' (prompt_pwd)
      set_color normal

      printf '%s ' (__fish_git_prompt)

      set_color normal
    end
  '';

  shellAliases = {
    # nvim is awkward to type on dvorak
    vim = "nvim";

    g = "git";

    # da comrade
    da = "direnv allow";
  };
}
