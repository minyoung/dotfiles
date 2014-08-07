export MARKPATH="${HOME}/.marks"

function jump {
  if [[ -z "$1" ]]; then
    marks
    return
  fi
  cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1"
}

function mark {
  mkdir -p $MARKPATH ; ln -s $(pwd) $MARKPATH/$1
}

function unmark {
  rm -i $MARKPATH/$1
}

function marks {
  ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- | column -t
  # ls -l $MARKPATH | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
  # ls -l $MARKPATH | awk '/->/ {printf("%-20s -> %s\n", $9, $11)}'
}

alias j=jump
