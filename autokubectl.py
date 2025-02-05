#!/usr/bin/env python3

import os, sys
import itertools
import gettext

NODE_LABELS_DEFAULT = [
    'kubernetes.io/arch',
    'node.kubernetes.io/instance-type',
    'topology.kubernetes.io/region',
    'topology.kubernetes.io/zone',
]

NODE_LABELS_EKS = NODE_LABELS_DEFAULT + [
    'eks.amazonaws.com/capacityType',
    'eks.amazonaws.com/nodegroup',
]

NODE_LABELS_KARPENTER = NODE_LABELS_DEFAULT + [
    'eks.amazonaws.com/capacityType',
    'karpenter.sh/capacity-type',
    'karpenter.k8s.aws/instance-cpu',
    'karpenter.k8s.aws/instance-memory',
]

NODE_LABELS_OCEAN = [
    'spotinst.io/node-lifecycle',
]

NODE_LABELS_AKS = NODE_LABELS_DEFAULT + [
    'kubernetes.azure.com/agentpool',
    'kubernetes.azure.com/storagetier',
    'kubernetes.azure.com/storageprofile',
]

NODE_LABELS_GKE = NODE_LABELS_DEFAULT + [
    'cloud.google.com/gke-nodepool',
    'cloud.google.com/machine-family',
]

VERB = {
    'H': 'HELP',
    'K': 'krew',
    'Ki': 'krew install %s',
    'a': 'apply',
    'ar': 'api-resources',
    'av': 'api-versions',
    'c': 'create',
    'ci': 'cluster-info',
    'd': 'describe',
    'dbg': 'debug -it %s',
    'dbgnet': 'debug -it %s --image=wbitt/network-multitool:extra -- bash',
    'dbgno': 'debug -it --image=alpine "node/%s" -- chroot /host',
    'doc': 'explain %s',
    'docx': 'explore %s',
    'drain': 'drain --delete-emptydir-data --ignore-daemonsets',
    'ed': 'edit',
    'ex': 'exec -i -t',
    'g': 'get',
    'gev': 'get event --sort-by=.lastTimestamp',
    # AKS nodes
    'gnoa': f'get node -L={",".join(NODE_LABELS_AKS)}',
    # EKS nodes
    'gnoaks': '=@gnoa',
    'gnoe': f'get node -L={",".join(NODE_LABELS_EKS)}',
    'gnoeks': '=@gnoe',
    # GKE nodes
    'gnog': f'get node -L={",".join(NODE_LABELS_GKE)}',
    'gnogke': '=@gnogke',
    # Karpenter+EKS nodes
    'gnok': f'get node -L={",".join(NODE_LABELS_KARPENTER)}',
    'gnokar': '=@kgnok',
    # Ocean nodes
    'gnoocean': f'get node -L={",".join(NODE_LABELS_OCEAN)}',
    # Node taints
    'gnot': 'get node -o template=\'NAME TAINTS...{{"\\n"}}{{range .items}}{{.metadata.name}}{{range .spec.taints}} {{.key}}{{if .value}}={{.value}}{{end}}:{{.effect}}{{end}}{{"\\n"}}{{end}}\' | column -t',
    'k': 'kustomize',
    'lo': 'logs',
    'lof': 'logs -f',
    'lop': 'logs -f -p',
    'p': 'proxy',
    'pf': 'port-forward',
    # https://gist.github.com/caruccio/245ecf15d35b4496d86d5c86bebe66f0
    'pfz': 'pfz',
    # https://github.com/ssup2/kpexec
    'pex': 'pexec -it -T %s',
    'pexc': 'pexec -it -T %s -c %s',
    'pexg': 'pexec -it -T %s --cnsenter-gc',
    'pexgc': 'pexec -it -T %s -c %s --cnsenter-gc',
    'rm': 'delete',
    'run': 'run --rm --restart=Never --image-pull-policy=IfNotPresent -i -t --image=%s',
    'sc': 'scale --replicas=%s',
    'sh': [
        'exec', '-it', '%s', '--', 'sh', '-ic', '"test -e /bin/bash && exec /bin/bash -i || exec /bin/sh -i"'
    ],
    # Bottlerocket -- https://github.com/bottlerocket-os/bottlerocket/blob/develop/README.md#admin-container
    'shbr': 'exec -i -t %s -- apiclient exec -t control enter-admin-container',
    'shc': [
        'exec', '-it', '%s', '-c', '%s', '--', 'sh', '-ic', '"test -e /bin/bash && exec /bin/bash -i || exec /bin/sh -i"'
    ],
    't': 'top',
    'tn': 'top node',
    # kubectl-top_node_pod: https://gist.github.com/caruccio/756430d7a2de75cbd026d4dd5edd13c6
    'tnp': 'top-node-pod',
    'tp': 'top pod',
    # kubectl-use_version: https://gist.github.com/caruccio/7a5c3358d70dcbcc5e2409808b21c0d1
    'usever': 'use-version',
    'ver': 'version',
    # https://github.com/d-kuro/kubectl-fuzzy
    'z': 'fuzzy',
}

RES = {
    'cj': 'cronjob.batch',
    'cm': 'configmap',
    'cr': 'clusterrole.rbac.authorization.k8s.io',
    'crb': 'clusterrolebinding.rbac.authorization.k8s.io',
    'crd': 'crd.apiextensions.k8s.io',
    'dc': 'deploymentconfig.apps.openshift.io',
    'dep': 'deployment.apps',
    'ds': 'daemonset.apps',
    'ep': 'endpoints',
    'ev': 'event',
    'gr': 'gitrepository.source.toolkit.fluxcd.io',
    'hr': 'helmrelease.helm.toolkit.fluxcd.io',
    'hpa': 'horizontalpodautoscaler.autoscaling',
    'ic': 'ingressclass.networking.k8s.io',
    'ing': 'ingress.networking.k8s.io',
    'ingc': 'ingresscontroller.operator.openshift.io',
    'is': 'imagestream.image.openshift.io',
    'j': 'jobs.batch',
    'k': 'kustomization.kustomize.toolkit.fluxcd.io',
    'no': 'nodes',
    'ns': 'namespaces',
    'np': 'networkpolicy.networking.k8s.io',
    'pdb': 'poddisruptionbudget.policy',
    'po': 'pods',
    'pr': 'prometheusrule.monitoring.coreos.com',
    'prom': 'prometheus.monitoring.coreos.com',
    'pv': 'pv',
    'pvc': 'pvc',
    'rb': 'rolebinding.rbac.authorization.k8s.io',
    'ro': 'role.rbac.authorization.k8s.io',
    'route': 'route.route.openshift.io',
    'rs': 'replicaset.apps',
    'sa': 'serviceaccount',
    'sc': 'storageclass.storage.k8s.io',
    'sec': 'secret',
    'sm': 'servicemonitor.monitoring.coreos.com',
    'sts': 'statefulset.apps',
    'svc': 'service',
    'vap': 'validatingadmissionpolicies',
    'vapb': 'validatingadmissionpolicybindings'
}

OPT = {
    'L': '-L=%s',
    'all': '--all',
    'an': '--all-namespaces',
    'c': '--container %s',
    'dry': '--dry-run=none -o=yaml',
    'dryc': '--dry-run=client -o=yaml',
    'dryn': '--dry-run=none -o=yaml',
    'drys': '--dry-run=server -o=yaml',
    'f': '-f=%s',
    'force': '--force',
    'h': '--help',
    'i': '-i',
    'k': '-k',
    'l': '-l=%s',
    'n': '--namespace=%s',
    'nfs': '--namespace flux-system',
    'nh': '--no-headers',
    'now': '--now',
    'o': '-o=%s',
    'oj': '=@ojson',
    'ojp': '=@ojsonpath',
    'ojs': '=@ojson',
    'ojson': '-o=json',
    'ojsonpath': '-o=jsonpath=%s',
    'on': '=@oname',
    'oname': '-o=name',
    'otemplate': '-o=template=%s',
    'otpl': '=@otemplate',
    'ow': '=@owide',
    'owide': '-o=wide',
    'oy': '=@oyaml',
    'oyaml': '-o=yaml',
    'oyml': '=@oyaml',
    'p': '-p',
    'raw': '--raw %s',
    'r': '--recursive',
    'rm': '--rm',
    'sb': '--sort-by=%s',
    'sbct': '--sort-by=metadata.creationTimestamp',
    'sl': '--show-labels',
    'sys': '--namespace=kube-system',
    't': '-t',
    'v': '-v=%s',
    'w': '--watch',
}

PRE = {
    '-': '%s',
    '-t': 'time',
    '-w': 'watch -n %s --',
}

SUF = {
    '+': '%s',
    '+gr': '| grep %s',
}

#############################

MAPS_NAMES_ORDERED = ['VERB', 'RES', 'OPT', 'PRE', 'SUF']

MAPS_NAME_PLURAL = {
    'VERB': 'Verbs',
    'RES': 'Resources',
    'OPT': 'Options',
    'PRE': 'Prefixes',
    'SUF': 'Suffixes',
}

MAPS_FROM_NAME = {
    'VERB': VERB,
    'RES': RES,
    'OPT': OPT,
    'PRE': PRE,
    'SUF': SUF,
}


PREFIX = os.environ.get('AUTOKUBECTL_PREFIX', 'k')
KUBECTL = os.environ.get('AUTOKUBECTL_KUBECTL', 'kubectl')
AUTOKUBECTL_DEBUG = os.environ.get('AUTOKUBECTL_DEBUG', 'false').lower() in [ 'true', '1' ]
AUTOKUBECTL_DRYRUN = os.environ.get('AUTOKUBECTL_DRYRUN', 'false').lower() in [ 'true', '1' ]
AUTOKUBECTL_DRYRUN_AS_ALIAS = os.environ.get('AUTOKUBECTL_DRYRUN_AS_ALIAS', 'false').lower() in [ 'true', '1' ]
SHOWKUBECTL_COMMAND = os.environ.get('SHOWKUBECTL_COMMAND', 'true').lower() in [ 'true', '1' ]

SHELL = 'sh'

if 'SHELL' in os.environ:
    SHELL = os.environ['SHELL']

if 'AUTOKUBECTL_SHELL_BASH' in os.environ:
    SHELL = os.environ['AUTOKUBECTL_SHELL_BASH']

SHELL = os.path.basename(SHELL)

gettext.bindtextdomain('autokubectl', os.path.dirname(os.path.realpath(sys.argv[0])))
_ = gettext.gettext
_d = gettext.dgettext

def load_config():
    for config_file in [ '/etc/autokubectl', os.path.expanduser(os.environ.get('AUTOKUBECTLRC', '~/.autokubectl')) ]:
        try:
            import yaml
            with open(config_file, 'r') as cf:
                config = yaml.safe_load(cf)
                for config_map_name, config_map_values in config.items():
                    if config_map_name in ['verb', 'verbs']:
                        MAP = VERB
                    elif config_map_name in ['res', 'resource', 'resources']:
                        MAP = RES
                    elif config_map_name in ['opt', 'option', 'options']:
                        MAP = OPT
                    elif config_map_name in ['pre', 'prefix', 'prefixes']:
                        MAP = PRE
                    elif config_map_name in ['suf', 'suffix', 'suffixes', 'pos', 'postfix', 'postfixes']:
                        MAP = SUF
                    else:
                        continue

                    for m_name, m_value in config_map_values.items():
                        if MAP == PRE:
                            m_name = f'-{m_name}'
                        elif MAP == SUF:
                            m_name = f'+{m_name}'
                        MAP[m_name] = m_value
        except (ModuleNotFoundError, FileNotFoundError) as ex:
            pass

def show_help(what=None):
    what = what if what in [ i[0].lower() for i in MAPS_NAMES_ORDERED ] else None

    if not what:
        print(_('%s: usage: ') % 'autokubectl' + 'k[verb][resource][options...|-prefix...|+suffix...]', file=sys.stderr)
        print(file=sys.stderr)

    for name in MAPS_NAMES_ORDERED:
        if what and what != name[0].lower():
            continue

        plural = MAPS_NAME_PLURAL[name]
        MAP = MAPS_FROM_NAME[name]

        print(plural, file=sys.stderr)
        print('-' * len(plural), file=sys.stderr)

        l = max(map_ranges(MAP)) + 2
        for k in sorted(MAP.keys()):
            print(f'{k:>{l}}: {MAP[k]}', file=sys.stderr)
        if not what:
            print(file=sys.stderr)

    if what:
        return

    print(_('Examples'), file=sys.stderr)
    print('-' * len(_('Examples')), file=sys.stderr)

    global SHOWKUBECTL_COMMAND
    SHOWKUBECTL_COMMAND = False

    examples = [
        ['kgpo'],
        ['kgpon', 'kube-system'],
        ['kgpoansl'],
        ['ksysgds'],
        ['kgposlan', '-v=6'],
        ['kafn', 'pod.yaml', 'default'],
        ['kgns-w3'],
        ['kgno-', 'echo'],
        ['kgno-+', 'echo DRY: [', ']'],
    ]
    l = max([ sum([ len(i) for i in ex ]) for ex in examples ]) + 6
    for ex in examples:
        cmd, parm = parse_command(ex)
        ex = ' '.join([ (f'"{i}"' if ' ' in i else i) for i in ex ])
        print(f"{ex:<{l}} --> {' '.join(cmd)} {' '.join(parm)}", file=sys.stderr)

    print(file=sys.stderr)
    print(_('Please refer to https://github.com/caruccio/autokube for instructions.'), file=sys.stderr)


def print_error(message):
    print(message, file=sys.stderr)


def startswith(obj, value):
    try:
        return obj.startswith(value)
    except:
        return obj[0].startswith(value) if obj else False


def map_ranges(MAP):
    return sorted(set([ len(k) for k in MAP ] ), reverse=True)


def remove_trailing_non_digit(value):
  return ''.join(list(reversed(list(itertools.dropwhile(lambda i: not i.isdigit(), reversed(value))))))


def dump(i, tag, **kvargs):
    if AUTOKUBECTL_DEBUG:
        print(f'{tag}[{i}]>', ', '.join([ f'{k}:{v}' for k, v in kvargs.items()]), file=sys.stderr)


def resolve_menmonic(input_command, mlen, MAP, i=-1, tag=''):
    dump(i, tag, resolve_menmonic=f'> input_command={input_command} - mlen={mlen}')
    assert input_command and mlen and MAP, f'input_command={input_command}, mlen={mlan}, MAP.len={len(MAP)}'
    current_mnemonic = input_command[0:mlen]
    current_mnemonic_value = MAP.get(current_mnemonic)
    if current_mnemonic_value and startswith(current_mnemonic_value, '=@'):
        dump(0, '@A', cur=current_mnemonic, val=current_mnemonic_value)
        current_mnemonic = current_mnemonic_value[2:]
        dump(0, '@A', cur=current_mnemonic, val=current_mnemonic_value)
        assert current_mnemonic, f'current_mnemonic="{current_mnemonic}"'
        current_mnemonic_value = MAP.get(current_mnemonic)

    dump(i, tag, resolve_menmonic=f'< current_mnemonic={current_mnemonic} - current_mnemonic_value={current_mnemonic_value}')
    return current_mnemonic, current_mnemonic_value


def parse_command(argv):
    assert argv

    original_command, original_parameters = argv[0], argv[1:]
    current_params, pre_command, suf_command = list(), list(), list()

    dump(0, '', ocmd=original_command)
    dump(0, '', opar=original_parameters)

    if not original_command.startswith(PREFIX):
        print_error(f'{SHELL}: ' + _d(SHELL, '%s: command not found') % argv[0])
        sys.exit(127)

    input_command = original_command[len(PREFIX):]

    dump(0, 'S', input=input_command)

    i = -1
    has_mnemonic, has_verb, has_resource = False, False, False
    current_mnemonic, current_mnemonic_value = '', ''
    mnemonic_len = 0

    while input_command:
        current_mnemonic, current_mnemonic_value = '', ''
        has_mnemonic = False
        mnemonic_len = 0

        i += 1
        dump(i, 'l1', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

        ## Verbs
        if (not has_mnemonic) and (not has_verb):
          for mlen in map_ranges(VERB):
            current_mnemonic, current_mnemonic_value = resolve_menmonic(input_command, mlen, VERB, i=i, tag='VE')
            dump(i, 'VE', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

            if not current_mnemonic_value:
                continue

            has_mnemonic = has_verb = True
            mnemonic_len = mlen
            break

        dump(i, 'l2', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

        # Resources
        if (not has_mnemonic ) and (not has_resource):
          for mlen in map_ranges(RES):
            current_mnemonic, current_mnemonic_value = resolve_menmonic(input_command, mlen, RES, i=i, tag='RE')
            dump(i, 'RE', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

            if not current_mnemonic_value:
                continue

            has_mnemonic = has_resource = True
            mnemonic_len = mlen
            break

        dump(i, 'l3', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

        # Options
        if not has_mnemonic:
          for mlen in map_ranges(OPT):
            current_mnemonic, current_mnemonic_value = resolve_menmonic(input_command, mlen, OPT, i=i, tag='OP')
            dump(i, 'OP', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

            if not current_mnemonic_value:
                continue

            has_mnemonic = True
            mnemonic_len = mlen
            break

        dump(i, 'l4', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

        # Prefix
        if not has_mnemonic:
          for mlen in map_ranges(PRE):
            current_mnemonic, current_mnemonic_value = resolve_menmonic(input_command, mlen, PRE, i=i, tag='PR')
            dump(i, 'PR', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

            if not current_mnemonic_value:
                continue

            has_mnemonic = True
            mnemonic_len = mlen

            # treat watch as special case
            if current_mnemonic == '-w':
                ## transform '-w[n]' into 'watch -n [n]' (default n=2)
                # extract everything after found mnemonic
                # remove all trailing non-digit values to keep only the watch parameter for 'watch -n X', if any
                watch_n = remove_trailing_non_digit(input_command[mnemonic_len:])
                pre_command.append(current_mnemonic_value % (watch_n if watch_n else '2'))
                mnemonic_len += len(watch_n)
            else:
              pre_command.append(current_mnemonic_value)
            current_mnemonic_value = '' # avoid appending it
            break

        dump(i, 'l5', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

        # Suffix
        if not has_mnemonic:
          for mlen in map_ranges(SUF):
            current_mnemonic, current_mnemonic_value = resolve_menmonic(input_command, mlen, SUF, i=i, tag='SU')
            dump(i, 'SU', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

            if not current_mnemonic_value:
                continue

            has_mnemonic = True
            mnemonic_len = mlen
##          ## CASO:
##          ##  suffix.spec : "| yq .spec"
##          ## kgcjoy+spec atualizacaolid-cronjob
##          if '%' not in current_mnemonic_value:
##              pass
            suf_command.append(current_mnemonic_value)
            current_mnemonic_value = ''
            break

        dump(i, 'l6', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))

        if (not has_mnemonic ) or (not mnemonic_len):
          break

        if current_mnemonic_value == 'HELP':
            show_help(original_parameters[0] if original_parameters else None)
            #autokubectl ${current_mnemonic_value,,} $@
            #${AUTOKUBECTL_DEBUG:-false} && set +x || true
            return None, None

        if current_mnemonic_value:
            current_params.append([ current_mnemonic_value ] if isinstance(current_mnemonic_value, str) else current_mnemonic_value)

        dump(i, 'l6', input=input_command, len=mnemonic_len, cur=current_mnemonic, val=current_mnemonic_value, has=(has_mnemonic, has_verb, has_resource))
        input_command = input_command[mnemonic_len:]
    ## end while

    partial_command = pre_command + [ KUBECTL ] + list(itertools.chain(*current_params)) + suf_command

    if input_command:
        print_error(_('%s: invalid command parsing at "%s" (got: %s)') % (argv[0], input_command, partial_command))
        sys.exit(127)

    dump(i, 'fc', pcmd=partial_command)
    final_command = list(partial_command)
    final_parameters = list(original_parameters)
    fmt_specs = [ fmt for fmt in final_command if (('%' in fmt) and ('%%' not in fmt)) ]

    # we must now printf() all %-fmt into final command in the same order they where defined by user.
    # for example, `kgnpol default app=web` must resolve to printf 'kubectl get --namespace=%s pods -l %s' default app=web
    if fmt_specs:
        dump(i, 'fmt', opar=original_parameters, fpar=final_parameters, spec=fmt_specs)
         # eat first %-fmt params because they are now duplicated in final command
        final_parameters = final_parameters[len(fmt_specs):]
        # remove all non-%-fmt params to be used below
        fmt_specs_parameters = original_parameters[:len(fmt_specs)]

        if len(fmt_specs_parameters) != len(fmt_specs):
            print_error(_("Missing positional parameter(s): %s" % ' '.join(fmt_specs)))
            sys.exit(2)

        dump(i, 'fmt', fmt_specs_parameters=fmt_specs_parameters, fmt_specs=fmt_specs)
        final_command = ("\033".join(partial_command) % tuple(fmt_specs_parameters)).split("\033") #ESC

    final_command_and_parameters = ' '.join([
        ' '.join(final_command),
        ' '.join(final_parameters)
    ])

    if SHOWKUBECTL_COMMAND:
        print(f'\033[1;36m+\033[0;36m {final_command_and_parameters}\033[0m', file=sys.stderr)

    if AUTOKUBECTL_DRYRUN:
        return None, None

    elif AUTOKUBECTL_DRYRUN_AS_ALIAS:
        print(f'alias {original_command}=\'{final_command_and_parameters}\'')
        return None, None

    return final_command, final_parameters

if __name__ == '__main__':
    load_config()
    command, parameters = parse_command(sys.argv[1:])
    if command:
        print(' '.join(command), ' '.join(parameters))
