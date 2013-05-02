# env
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# options
setopt INC_APPEND_HISTORY SHARE_HISTORY
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

function set_title {
    if [[ "$TERM" == screen* ]]; then
        print -Pn "\ek$1:q\e\\"
    elif [[ "$TERM" == xterm* ]]; then
        print -Pn "\e]1;$1:q\a"
    fi
}

# auto titling stuff
function precmd {
    # more escaping is needed to cover all cases,
    # but good enough for a start...
    local home="$(echo $HOME | sed 's/\//\\\//g')"
    local where="$(pwd | sed "s/^$home/~/")"
    set_title "zsh - $where"
}

function preexec {
    # local foo="$2 "
    # local title=${${=foo}[1]}
    # ^^ = command - arguments
    local title="$2"
    set_title "$title"
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

function __git_prompt() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
    echo "(± $PR_GREEN${ref#refs/heads/})"
}

function __hg_prompt() {
    hg root &> /dev/null || return
    echo '(☿)'
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

[[ -r ${HOME}/.aliasrc ]] && source ${HOME}/.aliasrc

autoload -U compinit && compinit
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
