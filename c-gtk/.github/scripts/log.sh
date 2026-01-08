log () {
  local _type="1"        # 4, trace by default, 3 for warning
  local _kind="error:"   # warning message by default

  # Check if arguments are supplied
  if [ $# -eq 0 ]; then
    echo "$(tput bold)$(tput setaf $_type)$_kind$(tput sgr0)$(tput bold) no type supplied to log function!$(tput sgr0)"
    return 1
  fi

  if [[ $1 == "warn" ]]; then
    _type="3"
    _kind="warning:"
  elif [[ $1 == "trace" ]]; then
    _type="4"
    _kind="trace:"
  fi

  # Check if the message ($2) is supplied
  if [ -z "$2" ]; then
    echo "$(tput bold)$(tput setaf $_type)$_kind$(tput sgr0)$(tput bold) no message supplied to log function!$(tput sgr0)"
    return 1
  fi

  echo "$(tput bold)$(tput setaf $_type)$_kind$(tput sgr0)$(tput bold) $2.$(tput sgr0)"
}
