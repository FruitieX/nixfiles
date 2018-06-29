#if [[ "$XDG_VTNR" == 1 && -z "$DISPLAY" && -z "$TMUX" ]]; then
#    exec startx
#fi

~/bin/tmx
if [[ -z "$TMUX" ]]; then
    exit
fi

# Tell zsh how to find installed completions
for p in ''${(z)NIX_PROFILES}; do
  fpath+=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions)
done

source $HOME/.zprezto/init.zsh

unamestr=$(uname)

# Disable ctrl-s sending XOFF
stty ixany
stty ixoff -ixon

setopt DVORAK

# use the vi navigation keys (hjkl) besides cursor keys in menu completion
#bindkey -M menuselect 'h' vi-backward-char        # left
#bindkey -M menuselect 'k' vi-up-line-or-history   # up
#bindkey -M menuselect 'l' vi-forward-char         # right
#bindkey -M menuselect 'j' vi-down-line-or-history # bottom, unfortunately the command below interferes with this
bindkey -M viins 'jj' vi-cmd-mode # 'jj' takes you into cmd mode

# make search up and down work, so partially type and hit up/down to find relevant stuff
#bindkey '^[[A' up-line-or-search
#bindkey '^[[B' down-line-or-search
#bindkey -M vicmd 'k' up-line-or-search
#bindkey -M vicmd 'j' down-line-or-search

#ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
#source ~/.zsh-autosuggestions/autosuggestions.zsh

# Enable autosuggestions automatically
#zle-line-init() {
	#zle autosuggest-start
#}
#zle -N zle-line-init

# use ctrl+t to toggle autosuggestions(hopefully this wont be needed as
# zsh-autosuggestions is designed to be unobtrusive)
#bindkey '^T' autosuggest-toggle
# Accept suggestions without leaving insert mode
#bindkey '^f' vi-forward-word

# zsh-history-substring-search keybinds
#bindkey -M vicmd 'k' history-substring-search-up
#bindkey -M vicmd 'j' history-substring-search-down

#zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
#zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'l:|=* r:|=*'
#zstyle ':completion:*' max-errors 3
#zstyle ':completion:*' menu select=long
#zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
#zstyle :compinstall filename '/home/rasse/.zshrc'

#autoload -Uz compinit
#compinit
# End of lines added by compinstall

ulimit -c unlimited

# added by travis gem
[ -f /home/rasse/.travis/travis.sh ] && source /home/rasse/.travis/travis.sh

export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.yarn/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm/bin:$PATH"
export PYTHON=/run/current-system/sw/bin/python2

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /home/rasse/src/ECOM/backend/node_modules/tabtab/.completions/serverless.zsh ]] && . /home/rasse/src/ECOM/backend/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /home/rasse/src/ECOM/backend/node_modules/tabtab/.completions/sls.zsh ]] && . /home/rasse/src/ECOM/backend/node_modules/tabtab/.completions/sls.zsh[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
