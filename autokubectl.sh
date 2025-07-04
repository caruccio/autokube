#
# TODO: handle already existing command_not_found_handle function
#
# Inspired by:
# - https://github.com/ahmetb/kubectl-aliases
# - https://fedoraproject.org/wiki/Features/PackageKitCommandNotFound
#

command_not_found_handle()
{
  if ! ${AUTOKUBECTL_TESTING:-false}; then
    # only search for the command if we're interactive
    [[ $- == *"i"* ]] || return 127

    # don't run if bash command completion is being run
    [[ -n ${COMP_CWORD-} ]] && return 127

    # don't run if there's no kubectl binary
    if ! type -P kubectl &>/dev/null; then
      printf "%s: $(gettext -d ${SHELL##*/} -s '%s: command not found')\n" ${SHELL##*/} $1
      return 127
    fi
  fi

  SHOWKUBECTL_ENABLED=false \
    eval "$("$AUTOKUBECTL_BIN_PATH" "$@")"
}

if [[ -n "${ZSH_VERSION-}" ]]; then
  AUTOKUBECTL_BIN_PATH=$(dirname $(realpath $0))/autokubectl.py
  command_not_found_handler () {
    command_not_found_handle "$@"
  }
else
  AUTOKUBECTL_BIN_PATH=$(dirname $(realpath ${BASH_ARGV[0]}))/autokubectl.py
fi
