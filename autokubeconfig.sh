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

  if [ "$1" == -u ]; then
    if [ -v KUBECONFIG ]; then
      echo Unsetting KUBECONFIG=$KUBECONFIG
      unset KUBECONFIG
    fi
    return
  fi

  export KUBECONFIG="$(realpath $1)"

  if ! [ -e "$1" ]; then
    echo Creating kubeconfig: $1
    touch $1
  else
    chmod 700 $KUBECONFIG
  fi

  echo -e "\033[32mUsing kubeconfig: ${KUBECONFIG}\033[0m"
}

