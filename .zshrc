# env
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# options
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt PROMPT_SUBST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt NO_BEEP
setopt AUTO_CD
setopt EXTENDED_GLOB
set MULTIOS
set CORRECT
bindkey -v
unsetopt FLOW_CONTROL
setopt NO_FLOW_CONTROL

bindkey "^R" history-incremental-search-backward

# used in precmd for time calculations
zmodload zsh/mathfunc

function set_title {
    if [[ "$TERM" == screen* ]]; then
        print -Pn "\ek$1:q\e\\"
    elif [[ "$TERM" == xterm* ]]; then
        print -Pn "\e]1;$1:q\a"
    fi
}

function precmd {
    # auto titling stuff
    # good enough for a start...
    set_title "zsh - ${$(pwd)/$HOME/~}"

    if [[ -z "$LAST_COMMAND_ID" ]]; then
        return
    fi

    count-commands.py log_command_end $LAST_COMMAND_ID
    unset LAST_COMMAND_ID
}

function preexec {
    # local command=${${=${2}}[1]}
    # ^^ = command line - arguments
    set_title "$2"

    export LAST_COMMAND_ID=$(uuidgen)
    count-commands.py log_command $LAST_COMMAND_ID $@
}

u () {
    set -A ud
    ud[1+${1-1}]=
    cd ${(j:../:)ud}
}

# colour stuff
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
    (( count = $count + 1 ))
done
PR_NO_COLOR="%{$terminfo[sgr0]%}"

function __find_toplevel() {
    local d
    d=$PWD
    while : ; do
        if test -d "$d/$1" ; then
            echo "$d"
            return
        fi
        test "$d" = / -o "$d" = "$HOME" && break
        d=$(cd "$d/.." && echo "$PWD")
    done
}

function __git_prompt() {
    local ref
    ref=$(git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
    echo "$PR_CYAN(± ${ref#refs/heads/})$PR_NO_COLOR"
}

function __hg_prompt() {
    local hg
    hg=$(__find_toplevel ".hg")
    if test -n "$hg" ; then
        local br file
        for file in "$hg/.hg/bookmarks.current" "$hg/.hg/branch" ; do
          test -f "$file" && { read br < "$file" ; break; }
        done
        echo "$PR_CYAN(☿ $br)$PR_NO_COLOR"
    fi
}

# TP_RED="`tput setaf 1`"
# TP_GREEN="`tput setaf 2`"
# TP_YELLOW="`tput setaf 3`"
# TP_BLUE="`tput setaf 4`"
# TP_MAGENTA="`tput setaf 5`"
# TP_CYAN="`tput setaf 6`"
# TP_WHITE="`tput setaf 7`"

# TP_BOLD="`tput bold`"
# TP_RST="`tput sgr0`"

# PS1="$PR_GREEN%n $PR_BLUE%2c %(!.#.$)$PR_NO_COLOR "

PS1='$PR_GREEN%n${PROMPT_HOST}\
$(__git_prompt)$(__hg_prompt)\
 $PR_BLUE%~\
 %(?.$PR_BLUE.$PR_RED)
%(!.#.$)$PR_NO_COLOR '
RPROMPT='$PR_YELLOW$(date "+%F %T %Z")$PR_NO_COLOR'

if [[ -s "${HOME}/.sh/prompt/errorcode.sh" ]]; then
    source "${HOME}/.sh/prompt/errorcode.sh"
    precmd_functions+=(_errorcode_prompt)
fi

fpath=($HOME/.zsh/completion $fpath)
autoload -U compinit && compinit -i
zmodload zsh/complist
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1     # Because we didn't really complete anything
}
zstyle ':completion:::::' completer _force_rehash _complete _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'
# zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:corrections' format "- %d - (errors %e})"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*' menu select
zstyle ':completion:*' verbose yes

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

compdef '_files -g "*.py"' python
compdef _gnu_generic python ln

# doesn't work very well :(
# zstyle ':completion:*:*:*:*:processes' menu yes select
# zstyle ':completion:*:*:*:*:processes' force-list always
# compdef pkill=kill
# zstyle ':completion:*:processes-names' command  'ps c -u ${USER} -o command | uniq'

zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:(cd|mv|cp):*' ignore-parents parent pwd
zstyle ':completion:*:(rm|kill|diff|cp|mv):*' ignore-line yes

unsetopt EXTENDED_HISTORY
unsetopt extendedhistory

__git_files () {
    _wanted files expl "local files" _files
}

[[ -r ${HOME}/.aliasrc ]] && source ${HOME}/.aliasrc
