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
    echo $KUBECONFIG;
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
    export KUBECONFIG="$(realpath "$1")"

    if ! [[ -e "$1" ]]; then
      echo Creating kubeconfig: $1
      touch "$1"
    else
      chmod 700 "$KUBECONFIG"
    fi
  fi

  echo -e "\033[36mUsing kubeconfig: ${KUBECONFIG}\033[0m"
}
