export BROWSER="google-chrome-stable"
export EDITOR="nvim"
export VISUAL="nvim"
export DISPLAY=":0"
#export PAGER="vimpager"

export LC_ALL="en_US.UTF-8"

unamestr=$(uname)

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  $path
)

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

# Temporary Files
if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$USER"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
  mkdir -p "$TMPPREFIX"
fi

if [[ $unamestr == 'Darwin' ]]; then
    export ANDROID_HOME="${HOME}/Library/Android/sdk"
    export ANDROID_SDK_ROOT="${HOME}/Library/Android/sdk"
else
    #export JAVA_HOME="/usr/lib/jvm/default"
    export ANDROID_HOME="${HOME}/Android/Sdk"
    #export ANDROID_SDK_ROOT="${HOME}/apps/android-sdk"
fi

export NPM_PACKAGES="${HOME}/.npm-packages"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export PATH="${HOME}/bin:${HOME}/dev/sh:${HOME}/apps/android-sdk/sdk/tools:${HOME}/apps/android-sdk/sdk/platform-tools:${HOME}/apps/android-sdk/ndk/android-ndk-r8d:${HOME}/.gem/ruby/2.2.0/bin:${NPM_PACKAGES}/bin:${PATH}"
export PATH="/usr/local/heroku/bin:$PATH"

# yarn crap
export PATH="$HOME/.yarn/bin:$PATH"

if [ -f $HOME/.zprofile.secret ]; then
    source $HOME/.zprofile.secret
fi

# nvm crap
if [[ $unamestr == 'Darwin' ]]; then
    export NVM_DIR="$HOME/.nvm"
    . "$(brew --prefix nvm)/nvm.sh"
fi

unset MANPATH
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"

if [[ $unamestr == 'Darwin' ]]; then
    export PATH="/usr/local/heroku/bin:${HOME}/.android-sdk-macosx/platform-tools:$PATH"
    export GDK_SCALE=2
else
    eval "$(dircolors ~/.dir_colors)"
fi

function md2pdf() {
    infile="$1"
    pandoc -f markdown -t latex $infile -o ${infile%.md}.pdf
}

alias open="xdg-open"
alias gl="git pull"
alias sys="systemctl"
alias sysu="systemctl --user"
alias jrn="journalctl"
alias jrnu="journalctl --user-unit"
alias sudo="sudo " # fix running aliases as sudo
alias vim="nvim"
alias hc="herbstclient"

# react native aliases
alias ra="react-native run-android"
alias ri="react-native run-ios"
alias rr="adb shell input text rr"
alias rd="adb shell input keyevent 82"

# shorthand for nix-shell --run
# passes all arguments to --run flag
nr() { nix-shell --run "$*" }
