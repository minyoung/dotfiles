[[ -r ${HOME}/.profilerc ]] && source ${HOME}/.profilerc

if [[ -z ${PROMPT_HOST} ]]; then
    PROMPT_HOST="@`hostname` "
fi
