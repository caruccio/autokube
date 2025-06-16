#!/bin/bash

passed=true
export SHOWKUBECTL_COMMAND=false

function run_test()
{
    local result="$(./autokubectl.py $1)"
    local expected="$2"

    if [ "$result" == "$expected" ]; then
        echo -ne "$(tput setaf 2)[PASSED]$(tput sgr0) "
        echo -e "$1 -> $result"
    else
        echo -ne "$(tput setaf 1)[FAILED]$(tput sgr0) "
        passed=false
        echo -e "$1:\nResult:   $result\nExpected: $expected"
    fi
}

run_test 'kgpo' 'kubectl get pods'
run_test 'kgpo nome1 nome2' 'kubectl get pods nome1 nome2'
run_test 'kgpon default' 'kubectl get pods --namespace=default'
run_test 'k:cgpo' 'kubectl color get pods'
run_test 'k:cgnok' 'kubectl color get node -L=kubernetes.io/arch,node.kubernetes.io/instance-type,topology.kubernetes.io/region,topology.kubernetes.io/zone,eks.amazonaws.com/capacityType,karpenter.sh/capacity-type,karpenter.k8s.aws/instance-cpu,karpenter.k8s.aws/instance-memory'
