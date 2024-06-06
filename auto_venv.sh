# shellcheck source=/dev/null
# manage python venv

export AUTO_VENV_ALLOW_FILE=~/.auto_venv_allow
function auto_venv_allowed() {
    touch "$AUTO_VENV_ALLOW_FILE"
    grep -E "^$PWD\$" "$AUTO_VENV_ALLOW_FILE"
}

function evaluate_permissions() {
    if [ "$(id -u)" = "$(stat -f "%u" "$1")" ]; then
        if [[ -r "$1" ]]; then
            return 0
        fi
    fi
    return 1
}

function evaluate_venv() {
  if [[ -z "$VIRTUAL_ENV" ]] ; then
      local activate_path
      ## If env folder is found then activate the vitualenv
      if [[ -d ./.env ]] ; then
          activate_path=./.env/bin/activate
      elif [[ -d ./.venv ]]; then
          activate_path=./.venv/bin/activate
      fi
      if [[ -n $activate_path ]]; then
          if [[ -n $(auto_venv_allowed) ]] ; then
              if evaluate_permissions "$activate_path"; then
                  source "$activate_path"
              else
                  echo "Permissions on ${activate_path} not valid. Auto env did not activate." 1>&2
              fi
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
    echo "$PWD" >> "$AUTO_VENV_ALLOW_FILE"
    local allow_list
    allow_list=$(sort "$AUTO_VENV_ALLOW_FILE" | uniq )
    echo "$allow_list" > "$AUTO_VENV_ALLOW_FILE"
    evaluate_venv
}

function auto_venv_disallow() {
    touch ~/.auto_venvrc 
    local allow_list
    allow_list=$(grep -Ev "^$PWD\$" "$AUTO_VENV_ALLOW_FILE")
    echo "$allow_list" > "$AUTO_VENV_ALLOW_FILE"
    if [[ -n "$VIRTUAL_ENV" ]] ; then
        deactivate
    fi
}

function cd() {
  builtin cd "$@" || return
  evaluate_venv
}
