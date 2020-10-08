{ pkgs, ... }:

{
  # Zsh shell configuration
  enable = true;

  shellAliases = {
    # nvim is awkward to type on dvorak
    vim = "nvim";

    # da comrade
    da = "direnv allow";

    g = "git";

    gpc = "git push --set-upstream origin $(git symbolic-ref HEAD 2> /dev/null | sed s-refs/heads/--)";
  };

  interactiveShellInit = ''
    mkdir -p $HOME/.tmux
    export TMUX_TMPDIR=$HOME/.tmux

    # Launch in tmux session if we're not already in one
    if [[ -z $TMUX ]]; then
      exec tmux new-session -t 0 \; set-option destroy-unattached
    fi

    # LS colors
    eval "''$(${pkgs.coreutils}/bin/dircolors ${./dircolors.base16.dark})"

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

    eval "$(direnv hook zsh)"
  '';
}
