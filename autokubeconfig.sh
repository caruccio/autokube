#
# TODO: handle prefixed kubeconfig file (ex: kubeconfig-kind, kubeconfig-dev, ...)
#

function cd_kubecfg()
{
  [[ -e ./.kubeconfig ]] && kubecfg ./.kubeconfig && return 0
  [[ -e ./kubeconfig ]] && kubecfg ./kubeconfig && return 0
  [[ -e ./.kube/config ]] && kubecfg ./.kube/config && return 0
  return 0
}

if [[ -n "${ZSH_VERSION-}" ]]; then
    chpwd_functions+=(cd_kubecfg)
else
    function cd()
    {
        command cd "$@"
        cd_kubecfg
    }
fi

function kubecfg()
{
  if [ $# -eq 0 ]; then
    [ -n "$KUBECONFIG" ] && echo "$KUBECONFIG" || :
    return 0
  fi

  local DEFAULT_KUBECONFIG=.kubeconfig

  if [[ "$1" == -h ]]; then
    echo "This command creates a new \`$DEFAULT_KUBECONFIG\` file if not exists, and set it into the environment variable \$KUBECONFIG."
    echo
    echo "Usage: kubecfg [OPTION] [FILENAME]"
    echo "Options:"
    echo " -h    This help message"
    echo " -i    Interactivelly select existing kubeconfig file from current directory"
    echo " -p    Print current \$KUBECONFIG"
    echo " -u    Unset \$KUBECONFIG"
    echo
    echo "If FILENAME is provided, use it as the kubeconfig filename."
    echo "It will search for this filenames by default: \`$DEFAULT_KUBECONFIG\` (default), \`kubeconfig\`, \`.kube/config\` and its glob version (Ex: \`.kubeconfig*\` -> \`.kubeconfig-prd\`, \`.kubeconfig-dev\` ...)"
    return 0
  fi

  # Unset KUBECONFIG env
  if [[ "$1" == -u ]]; then
    if [[ -v KUBECONFIG ]]; then
      echo "Reseting KUBECONFIG (was '$KUBECONFIG')"
      unset KUBECONFIG
    fi
    return 0
  fi

  # Interactive select kubeconfig file
  if [[ "$1" == -i ]]; then
    local config
    local found=()
    for config in ./.kubeconfig* ./kubeconfig* ./.kube/config*; do
      [[ -e "$config" ]] && found+=("$config")
    done
    if [[ ${#found[*]} -eq 0 ]]; then
      echo No suitable kubeconfig file found
      return 0
    fi
    if type fzf 2>/dev/null; then
      KUBECONFIG=$(printf "%s\n" "${found[@]}" | fzf --select-1 --reverse)
      export KUBECONFIG="$(realpath "$KUBECONFIG")"
    else
      select config in "${found[@]}"; do
        export KUBECONFIG="$(realpath $config)"
      done
    fi
  else
    if [[ $# -eq 0 ]]; then
      export KUBECONFIG=$(realpath $DEFAULT_KUBECONFIG)
    else
      export KUBECONFIG="$(realpath "$1")"
    fi
  fi

  if ! [[ -e "$1" ]]; then
    echo Creating kubeconfig: $1
    touch "$1"
    chmod 600 "$KUBECONFIG"
  else
    chmod go-r "$KUBECONFIG" # newer kubectl will complain about too open files
  fi

  echo -e "\033[36mUsing kubeconfig: ${KUBECONFIG}\033[0m"
}
