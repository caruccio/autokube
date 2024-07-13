#!/bin/bash
#
# TODO: handle prefixed kubeconfig file (ex: kubeconfig-kind, kubeconfig-dev, ...)
#

function cd()
{
  command cd "$@"
  [ -e ./.kubeconfig ] && kubecfg ./.kubeconfig && return
  [ -e ./kubeconfig ] && kubecfg ./kubeconfig && return
  [ -e ./.kube/config ] && kubecfg ./.kube/config && return
}

function kubecfg()
{
  if [ $# -eq 0 ]; then
    echo $KUBECONFIG;
    return
  fi

  # Unset KBUECONFIG env
  if [ "$1" == -u ]; then
    if [ -v KUBECONFIG ]; then
      echo Unsetting KUBECONFIG=$KUBECONFIG
      unset KUBECONFIG
    fi
    return
  fi

  # Interactive select kubeconfig file
  if [ "$1" == -i ]; then
    local config
    local found=()
    for config in ./.kubeconfig* ./kubeconfig* ./.kube/config*; do
      [ -e "$config" ] && found+=("$config")
    done
    if [ ${#found[*]} -eq 0 ]; then
      echo No suitable kubeconfig file found
      return
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

    if ! [ -e "$1" ]; then
      echo Creating kubeconfig: $1
      touch "$1"
    else
      chmod 700 "$KUBECONFIG"
    fi
  fi

  echo -e "\033[32mUsing kubeconfig: ${KUBECONFIG}\033[0m"
}

