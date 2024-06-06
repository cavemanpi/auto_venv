# manage python venv

export AUTO_VENV_ALLOW_FILE=~/.auto_venv_allow
function auto_venv_allowed() {
    touch "$AUTO_VENV_ALLOW_FILE"
    grep -E "^$PWD\$" "$AUTO_VENV_ALLOW_FILE"
}

function evaluate_venv() {
  if [[ -z "$VIRTUAL_ENV" ]] ; then
      local activate_path=""
      ## If env folder is found then activate the vitualenv
      if [[ -d ./.env ]] ; then
          activate_path=./.env/bin/activate
      elif [[ -d ./.venv ]]; then
          activate_path=./.venv/bin/activate
      fi
      if [[ ! -z $activate_path ]]; then
          if [[ ! -z $(auto_venv_allowed) ]] ; then
              source $activate_path
          fi
      fi
  else
    ## check the current folder belongs to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
      parentdir="$(dirname "$VIRTUAL_ENV")"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        deactivate
        evaluate_venv
      fi
  fi
}

function auto_venv_allow() {
    echo $PWD >> $AUTO_VENV_ALLOW_FILE
    local allow_list=$(sort "$AUTO_VENV_ALLOW_FILE" | uniq )
    echo "$allow_list" > "$AUTO_VENV_ALLOW_FILE"
    evaluate_venv
}

function auto_venv_disallow() {
    touch ~/.auto_venvrc 
    local allow_list=$(grep -v "$PWD" "$AUTO_VENV_ALLOW_FILE")
    echo $allow_list > "$AUTO_VENV_ALLOW_FILE"
    if [[ ! -z "$VIRTUAL_ENV" ]] ; then
        deactivate
    fi
}

function cd() {
  builtin cd "$@"
  evaluate_venv
}
