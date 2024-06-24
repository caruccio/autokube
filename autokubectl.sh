#!/bin/bash
#
# TODO: handle already existing command_not_found_handle function
#
# Inspired by:
# - https://github.com/ahmetb/kubectl-aliases
# - https://fedoraproject.org/wiki/Features/PackageKitCommandNotFound
#

## Verbs

declare -A autokube_command_not_found_handle_map_verb
#5
autokube_command_not_found_handle_map_verb[dbgno]='debug -it --image=alpine "node/%s" -- chroot /host'
#4
autokube_command_not_found_handle_map_verb[gnok]='get node -L=kubernetes.io/arch,eks.amazonaws.com/capacityType,karpenter.sh/capacity-type,karpenter.k8s.aws/instance-cpu,karpenter.k8s.aws/instance-memory' #AWS
# AKS
autokube_command_not_found_handle_map_verb[gnoz]='get node -L=kubernetes.io/arch,beta.kubernetes.io/instance-type'
# EKS+Bottlerocket -- https://github.com/bottlerocket-os/bottlerocket/blob/develop/README.md#admin-container
autokube_command_not_found_handle_map_verb[shac]='exec -i -t "%s" -- apiclient exec -t control enter-admin-container'
autokube_command_not_found_handle_map_verb[shbr]='exec -i -t "%s" -- apiclient exec -t control enter-admin-container'

#3
autokube_command_not_found_handle_map_verb[dbg]='debug -it "%s"'
autokube_command_not_found_handle_map_verb[lof]='logs -f'
autokube_command_not_found_handle_map_verb[lop]='logs -f -p'
autokube_command_not_found_handle_map_verb[run]='run --rm --restart=Never --image-pull-policy=IfNotPresent -i -t --image="%s"'
#2
autokube_command_not_found_handle_map_verb[ed]='edit'
autokube_command_not_found_handle_map_verb[ex]='exec -i -t'
autokube_command_not_found_handle_map_verb[Ki]='krew install "%s"'
autokube_command_not_found_handle_map_verb[lo]='logs'
autokube_command_not_found_handle_map_verb[pf]='port-forward'
autokube_command_not_found_handle_map_verb[rm]='delete'
autokube_command_not_found_handle_map_verb[sh]='exec -i -t "%s" -- sh -i -c "bash -i || exec sh -i"'
#1
autokube_command_not_found_handle_map_verb[a]='apply --recursive -f "%s"'
autokube_command_not_found_handle_map_verb[c]='create'
autokube_command_not_found_handle_map_verb[d]='describe'
autokube_command_not_found_handle_map_verb[g]='get'
autokube_command_not_found_handle_map_verb[H]='HELP'
autokube_command_not_found_handle_map_verb[k]='kustomize'
autokube_command_not_found_handle_map_verb[K]='krew'
autokube_command_not_found_handle_map_verb[p]='proxy'

## Resources

declare -A autokube_command_not_found_handle_map_res
#5
autokube_command_not_found_handle_map_res[route]='route'
#3
autokube_command_not_found_handle_map_res[crb]='clusterrolebinding'
autokube_command_not_found_handle_map_res[dep]='deployment'
autokube_command_not_found_handle_map_res[ing]='ingress'
autokube_command_not_found_handle_map_res[pvc]='pvc'
autokube_command_not_found_handle_map_res[sec]='secret'
autokube_command_not_found_handle_map_res[sts]='statefulset'
autokube_command_not_found_handle_map_res[svc]='service'
#2
autokube_command_not_found_handle_map_res[cm]='configmap'
autokube_command_not_found_handle_map_res[cr]='clusterrole'
autokube_command_not_found_handle_map_res[dc]='deploymentconfig'
autokube_command_not_found_handle_map_res[ds]='daemonset'
autokube_command_not_found_handle_map_res[ev]='event'
autokube_command_not_found_handle_map_res[is]='imagestream'
autokube_command_not_found_handle_map_res[no]='nodes'
autokube_command_not_found_handle_map_res[ns]='namespaces'
autokube_command_not_found_handle_map_res[po]='pods'
autokube_command_not_found_handle_map_res[pv]='pv'
autokube_command_not_found_handle_map_res[rb]='rolebinding'
autokube_command_not_found_handle_map_res[ro]='role'
autokube_command_not_found_handle_map_res[sa]='serviceaccount'

## Options

declare -A autokube_command_not_found_handle_map_opt
#7
autokube_command_not_found_handle_map_opt[ojsonpath]='-o=jsonpath="%s"'
autokube_command_not_found_handle_map_opt[otemplate]='-o=template="%s"'
#5
autokube_command_not_found_handle_map_opt[force]='--force'
autokube_command_not_found_handle_map_opt[ojson]='-o=json'
autokube_command_not_found_handle_map_opt[oname]='-o=name'
autokube_command_not_found_handle_map_opt[owide]='-o=wide'
autokube_command_not_found_handle_map_opt[oyaml]='-o=yaml'
#4
autokube_command_not_found_handle_map_opt[dryc]='--dry-run=client -o=yaml'
autokube_command_not_found_handle_map_opt[dryn]='--dry-run=none -o=yaml'
autokube_command_not_found_handle_map_opt[drys]='--dry-run=server -o=yaml'
autokube_command_not_found_handle_map_opt[otpl]='-o=template="%s"'
autokube_command_not_found_handle_map_opt[oyml]='-o=yaml'
#3
autokube_command_not_found_handle_map_opt[all]='--all'
autokube_command_not_found_handle_map_opt[dry]='--dry-run=none -o=yaml'
autokube_command_not_found_handle_map_opt[now]='--now'
autokube_command_not_found_handle_map_opt[ojp]='-o=jsonpath'
autokube_command_not_found_handle_map_opt[ojs]='-o=json'
autokube_command_not_found_handle_map_opt[raw]='--raw "%s"'
autokube_command_not_found_handle_map_opt[sys]='--namespace=kube-system'
#2
autokube_command_not_found_handle_map_opt[nh]='--no-headers'
autokube_command_not_found_handle_map_opt[oj]='-o=json'
autokube_command_not_found_handle_map_opt[on]='-o=name'
autokube_command_not_found_handle_map_opt[ow]='-o=wide'
autokube_command_not_found_handle_map_opt[oy]='-o=yaml'
autokube_command_not_found_handle_map_opt[rm]='--rm'
autokube_command_not_found_handle_map_opt[sb]='--sort-by="%s"'
autokube_command_not_found_handle_map_opt[sl]='--show-labels'
#1
autokube_command_not_found_handle_map_opt[A]='--all-namespaces'
autokube_command_not_found_handle_map_opt[h]='--help'
autokube_command_not_found_handle_map_opt[f]='--recursive -f="%s"'
autokube_command_not_found_handle_map_opt[i]='-i'
autokube_command_not_found_handle_map_opt[k]='-k'
autokube_command_not_found_handle_map_opt[l]='-l="%s"'
autokube_command_not_found_handle_map_opt[L]='-L="%s"'
autokube_command_not_found_handle_map_opt[n]='--namespace="%s"'
autokube_command_not_found_handle_map_opt[o]='-o="%s"'
autokube_command_not_found_handle_map_opt[p]='-p'
autokube_command_not_found_handle_map_opt[t]='-t'
autokube_command_not_found_handle_map_opt[v]='-v="%s"'
autokube_command_not_found_handle_map_opt[w]='--watch'

## watch

declare -A autokube_command_not_found_handle_map_prepend
autokube_command_not_found_handle_map_prepend[P]='%s'
# convenience for common cases
autokube_command_not_found_handle_map_prepend[T]='time'
autokube_command_not_found_handle_map_prepend[W]='watch -n %i --'

function autokubectl_test()
{
  if ! [ -e ~/.kubectl_aliases ]; then
    echo Error: file ~/.kubectl_aliases not found for comparison.
    return 1
  fi

  grep ^alias ~/.kubectl_aliases | sed -e 's/alias //' -e 's/=/ /' -e "s/'//g" | while read _alias _alias_c; do
    [ -v total ] && let total+=1 || local -i total=1
    [ -v pass ] || local -i pass=0

    _mne="$_alias"

    # translate different mnemonics
    if [[ $_mne =~ .*all.* ]]; then
      if ! [[ $_alias_c =~ .*delete.* ]]; then
        _mne=${_mne/all/A}
      fi
    fi
    if [[ $_mne =~ .*owide.* ]]; then
      _mne=${_mne/owide/ow}
    fi
    if [[ $_mne =~ .*lo.* ]] && [[ $_alias_c =~ .*logs.* ]]; then
      _mne=${_mne/lo/lof}
    fi
    if [[ $_mne =~ .*run.* ]] && [[ $_alias_c =~ .*run.* ]]; then
      _alias_c+=' --image=""'
    fi
    if [[ $_mne == kak ]]; then
      _alias_c=${_alias_c/-k/--recursive -f \"\" -k}
    fi

    # expected mnemonic command
    _mne_c=$(AUTOKUBECTL_DRYRUN=true AUTOKUBECTL_TESTING=true $_mne)

    if [ "$_alias_c" == "$_mne_c" ] || [ "$_alias_c=\"\"" == "$_mne_c" ] || [ "$_alias_c \"\"" == "$_mne_c" ]; then
      [ -v pass ] && let pass+=1
    else
      echo -e "\n$_alias:"
      echo "  '$_alias_c'"
      echo "  '$_mne_c'"
    fi

    echo -ne "Total: PASSED=$pass TOTAL=$total\r"
  done
  echo
}

function autokubectl()
{
  case "$1" in
    flush) autokubectl_flush $@ ;;
    help) autokubectl_help $@ ;;
    *) return 1
  esac
}

function autokubectl_flush()
{
  echo Flushing tables $$
  unset -v autokube_command_not_found_handle_map_verb
  unset -v autokube_command_not_found_handle_map_res
  unset -v autokube_command_not_found_handle_map_opt
  unset -v autokube_command_not_found_handle_map_prepend
}

function autokubectl_help()
{
  local c="$1"
  shift

  type tabulate &>/dev/null && local tab="tabulate --sep \| -f plain" || local tab=cat

  echo Available mnemonics
  echo

  if [ -z "$1" ] || [ "${1:0:1}" == v ]; then
    echo Verbs
    echo -----
    for i in $(printf "%s\n" ${!autokube_command_not_found_handle_map_verb[*]} | sort); do
      echo "  $i:|${autokube_command_not_found_handle_map_verb[$i]}"
    done | $tab
    echo
  fi

  if [ -z "$1" ] || [ "${1:0:1}" == r ]; then
    echo Resources
    echo ---------
    for i in $(printf "%s\n" ${!autokube_command_not_found_handle_map_res[*]} | sort); do
      echo "  $i:|${autokube_command_not_found_handle_map_res[$i]}"
    done | $tab
    echo
  fi

  if [ -z "$1" ] || [ "${1:0:1}" == o ]; then
    echo Options
    echo -------
    for i in $(printf "%s\n" ${!autokube_command_not_found_handle_map_opt[*]} | sort); do
      echo "  $i:|${autokube_command_not_found_handle_map_opt[$i]}"
    done | $tab
    echo
  fi

  if [ -z "$1" ] || [ "${1:0:1}" == w ]; then
    echo Watches
    echo -------
    for i in $(printf "%s\n" ${!autokube_command_not_found_handle_map_prepend[*]} | sort); do
      echo "  $i:|${autokube_command_not_found_handle_map_prepend[$i]}"
    done | $tab
    echo
  fi

  echo Please refer to https://github.com/caruccio/autokube for instructions.
}

command_not_found_handle()
{
  if ! ${AUTOKUBECTL_TESTING:-false}; then
    # only search for the command if we're interactive
    [[ $- == *"i"* ]] || return 127
    #
    # don't run if bash command completion is being run
    [[ -n ${COMP_CWORD-} ]] && return 127
  fi

  if [[ "${1:0:1}" != k ]]; then
    if [[ -n "${BASH_VERSION-}" ]]; then
      printf 'bash: %s: %s\n' "$1" "command not found" >&2
    fi

    return 127
  fi

  ${AUTOKUBECTL_DEBUG:-false} && set -x || true

  local original_command="$1"
  shift
  local original_parameters=("$@")

  local input_command=${original_command:1} ## extract mnemonics from command `k[input_command]`
  local current_params=()
  local prepend_command=()   ## prepend command
  local has_verb=false
  local has_resource=false

  while [ ${#input_command} -gt 0 ]; do
    local mnemonic_len=0
    local current_mnemonic=''
    local current_mnemonic_value=''
    local has_mnemonic=false

    if ! $has_mnemonic && ! $has_verb; then
      for len in 9 {5..1}; do
        current_mnemonic=${input_command:0:$len}
        current_mnemonic_value="${autokube_command_not_found_handle_map_verb[$current_mnemonic]}"
        if [ -n "$current_mnemonic_value" ]; then
          has_verb=true
          has_mnemonic=true
          mnemonic_len=$len
          break
        fi
      done
    fi

    if ! $has_mnemonic && ! $has_resource; then
      for len in 9 {5..1}; do
        current_mnemonic=${input_command:0:$len}
        current_mnemonic_value="${autokube_command_not_found_handle_map_res[$current_mnemonic]}"
        if [ -n "$current_mnemonic_value" ]; then
          has_resource=true
          has_mnemonic=true
          mnemonic_len=$len
          break
        fi
      done
    fi

    if ! $has_mnemonic; then
      for len in 9 {5..1}; do
        current_mnemonic=${input_command:0:$len}
        current_mnemonic_value="${autokube_command_not_found_handle_map_opt[$current_mnemonic]}"
        if [ -n "$current_mnemonic_value" ]; then
          has_mnemonic=true
          mnemonic_len=$len
          break
        fi
      done
    fi

    if ! $has_mnemonic; then
      for len in 9 {5..1}; do
        current_mnemonic=${input_command:0:$len}
        current_mnemonic_value="${autokube_command_not_found_handle_map_prepend[$current_mnemonic]}"
        if [ -n "$current_mnemonic_value" ]; then
          has_mnemonic=true
          mnemonic_len=$len
          # treat watch as special case
          if [ "$current_mnemonic" == 'W' ]; then
            ## transform 'W[N]' into 'watch -n N' (default N=2)
            local watch_n=${input_command:$mnemonic_len} # extract everything after found mnemonic
            watch_n=${watch_n%%[a-zA-Z]*}                # remove all leading non-numeric values to keep only the watch parameter for 'watch -n X', if any
            prepend_command+=( $(printf "${current_mnemonic_value}" ${watch_n:-2}) )
            let mnemonic_len+=${#watch_n} ## compute len(N)
          else
            prepend_command+=("${current_mnemonic_value}")
          fi
          current_mnemonic_value='' # avoid appending it
          break
        fi
      done
    fi

    if ! $has_mnemonic || [ $mnemonic_len -eq 0 ]; then
      break
    fi

    if [ "$current_mnemonic_value" == HELP ]; then
        autokubectl ${current_mnemonic_value,,} $@
        ${AUTOKUBECTL_DEBUG:-false} && set +x || true
        return
    fi

    current_params+=("$current_mnemonic_value")
    input_command=${input_command:$mnemonic_len}
  done

  if [ ${#input_command} -ne 0 ]; then
    if [[ -n "${BASH_VERSION-}" ]]; then
      printf 'bash: %s: %s\n' "$original_command" "command not found" >&2
    fi
    ${AUTOKUBECTL_DEBUG:-false} && set +x || true
    return 127
  fi

  local partial_command=("${prepend_command[@]}" kubectl "${current_params[@]}")
  local final_command="${partial_command[*]}"
  local final_parameters=("${original_parameters[@]}")
  local fmt_specs="${partial_command[@]//[^%]/}"
  fmt_specs="${fmt_specs// /}"

  # we must now printf() all %-fmt into final command in the same order they where defined by user.
  # for example, `kgnpol default app=web` must resolve to printf 'kubectl get --namespace=%s pods -l %s' default app=web
  if [ ${#fmt_specs} -gt 0 ]; then
    final_parameters=("${final_parameters[@]:${#fmt_specs}}") # eat first %-fmt params to they are now duplicated in final command
    local fmt_specs_parameters=("${original_parameters[@]:0:${#fmt_specs}}") # remove all non-%-fmt params to use below
    printf -v final_command "${partial_command[*]}" "${fmt_specs_parameters[@]}"
  fi

  if ${AUTOKUBECTL_DRYRUN_AS_ALIAS:-false}; then
    echo "alias $original_command='${final_command}${final_parameters:+ ${final_parameters[*]}}'"
    ${AUTOKUBECTL_DEBUG:-false} && set +x || true
    return
  fi

  if ${AUTOKUBECTL_DRYRUN:-false}; then
    echo "${final_command}${final_parameters:+ ${final_parameters[*]}}"
    ${AUTOKUBECTL_DEBUG:-false} && set +x || true
    return
  fi

  ${AUTOKUBECTL_DEBUG:-false} && set +x || true
  echo -e "\033[36m+ ${final_command}${final_parameters:+ ${final_parameters[*]}}\033[0m" >&2
  SHOWKUBECTL_ENABLED=false \
    eval "${final_command}${final_parameters:+ ${final_parameters[*]}}"
}
