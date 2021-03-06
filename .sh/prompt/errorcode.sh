# Print error code/signal names when a program exits in error
# Implementation shared between bashrc/zshrc
_errorcode_prompt() {
    local stat="$?"
    local E=$(printf '\e')
    local red="${E}[31;1m"
    local no_color="${E}[0;0m"
    if test "$stat" -ne 0; then
        # If process exited by a signal, determine name of signal.
        if test "$stat" -gt 128; then
            local signal="$(builtin kill -l $[$stat - 128] 2>/dev/null)"
            if test "$signal"; then
                signal=" ($signal)"
            fi
        fi
        echo "[${red}Exit $stat$signal${no_color}]" 1>&2
    fi
}
