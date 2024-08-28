# AutoKube Tools

Here lies my *swiss army knife* of kubernetes tools I use on a daily-basis.

> Please not all tools are built for BASH, SH and ZSH, but may be easy enough to port to other shells.
> Feel free to send PRs.

```sh
git clone https://github.com/caruccio/autokube
cd autokube
```

- [Install](#install)
- [AutoKubectl](#autokubectl): mnemonic kubectl command generator.
- [AutoKubeconfig](#autokubeconfig): switch KUBECONFIG file as you `cd` into a new directory.
- [ShowKubectl](#showkubectl): print final kubectl command before executing it.

# Install

To install for the current user only (bash/sh/zsh):

```
make install-user
```

To install system-wide (bash/sh only):

```
sudo make install
```

Files will be installed into `/etc/profile.d`. Just start a new shell section to use it.

Files are `source`ed from the current directory (where you cloned it) on your RC file (`~/.bashrc`, `~/.zshrc` or `~/.profile`).
Either start a new shell session or source it (ex: `source ~/.bashrc` or `source ~/.zshrc`)

--------------------

# AutoKubectl

**Mnemonic kubectl command generator**

## AutoKubectl -- Usage

Tired of typing `kubectl get event -w -n=default -v=3 -o=json`?

Try this instead: `kgevwnvoj default 3`

**ALERT: This is not a shell alias**

Inspired by [ahmetb's kubectl-aliases](https://github.com/ahmetb/kubectl-aliases), this tool will resolve an alias-like command to kubectl.

Take, for instance, both commands below.

```sh
kgevwnvoj default 3
kwojgevvn 3 default
```

Each one will expand for the following commands respectively.

```sh
kubectl get event -w -n=default -v=3 -o=json
kubectl -w -o=json get event -v=3 -n=default
```

Where:

```
Mnemonic    Resolves To     Mnemonic Class
k       --> kubectl
g       --> get             [verb]
ev      --> event           [resource]
w       --> -w              [option]
n       --> namespace=$1    [option + $1]
v       --> -v=$2           [option + $2]
oj      --> -o=json         [option]
```

The only rule is to follow the given order:

```
k -> [verb] -> [resource] -> [option|prefix|suffix]
```

There is no order within each class of mnemonics.

## AutoKubectl -- Prefix and suffix commands

You can prefix and suffix to the final command. Mnemonic starting with `-` are inserted in front of the command, and those starting with `+` are appended.

```sh
kgpoojn-w1+gr kube-system apiserver
```

Becomes:
```
watch -n 1 -- kubectl get pods -o=json --namespace="kube-system" | grep "apiserver"
+-----------+         +-+ +--+ +-----+ +-----------------------+ +----------------+
      |                |    |     |              |                       |
  [prefix + [N]]    [verb]  |  [option]    [options + $1]             [append]
                            |
                       [resources]
```

> Note `-w` is treated special. It accepts a numeric value after the `w` to be used by `watch`'s parameter `-n [N]`.
> If `[N]` is omited, like `kgpo-w`, the default value `2` is used.

## AutoKubectl -- How it works

It defines the special bash function `command_not_found_handle` (command_not_found_handler for zsh) to intercept commands not found.
The function walks char-by-char of the first parameter (ths command itself), searching for the longest mnemonic sequence on a dictionary,
translating one or more characters into kubectl verbs, resources and options.

You can see all available mnemonics by executing `kH` (H stands for help).

The dictionaries can be expanded or modified with your custom mappings. It will look for configs in the fiels `/etc/autokubectl` and `~/.autokubectl`
(or from file defined in env `AUTOKUBECTLRC`.

The file format is a simple yaml like this:

```yaml
verb:
    wapo: wait --for=condition=Ready pod/%s
    poev: alpha events --for pod/%s
    ## https://kubepug.xyz/
    pug: deprecations

resource:
    hr: helmrelease
    hrepo: helmrepository

options:
    v5: -v=5
    v6: -v=6

prefix:
    dry: "echo DRY:"

suffix:
    wcl: "--no-headers | wc -l"
```

Now you can use your custom mnemonics:

```sh
$ kpug       --> kubectl deprecations
$ kghran     --> kubectl get hr --all-namespace
$ kgnsw-dry  --> echo DRY: kubectl get namespaces --watch
$ kgpo+wcl   --> kubectl get pods --no-headers | wc -l
```

If var `AUTOKUBECTL_DRYRUN=true`, then no command is executed, and the resulting expansion is shown in stdout:

```sh
$ AUTOKUBECTL_DRYRUN=true  \
  kgevwnvoj default 3
kubectl get event -w -n="default" -v="3" -o=json
```

## AutoKubectl -- Disclaimer

This method may conflicts with other tools that install a "command not found" handler function.
For example, Fedora-like distros often comes with package [PackageKit-command-not-found](https://fedoraproject.org/wiki/Features/PackageKitCommandNotFound) installed.
This packages provides the file `/etc/profile.d/PackageKit.sh` with a single function `command_not_found_handle`, which is called by `bash` when a command you typed is not found.
That is how it can suggest speelling corretions or even packages for that uninstalled command in your system.

You can see [this sections of bash's manual](https://www.gnu.org/software/bash/manual/bash.html#Command-Search-and-Execution) for details.

The problem is that files from `/etc/profile.d` are `source`ed on boot, with no garantees that our file will overwrite PackageKit-command-not-found's function.

That said, you can only have one "command not found" function handler (for now). Thus, either you uninstall PackageKit-command-not-found or source autokubectl.sh from your `~/.bashrc`:

## AutoKubectl -- Caveats

There are problems with this method? Of course there are!! Who do you think I'm?! Dennis Ritchie?!

Sometimes you will face ambiguity, but I can live with that... Fell free to fix and send me a PR.

For example `kgno`: is this `kubectl get node` or `kubect get -n=$1 -o=$2`?

Turns out the longest mnemonic matches first, thus `no` (2 chars) will match as `node`, not `n` (1 char) + `o` (1 char).

## AutoKubectl -- Help

Use the command `kH` to show help.

```sh
$ kH
Usage: k[verb][resource][options...|-prefix...|+suffix...]

Verbs
-----
      H: HELP
      K: krew
     Ki: krew install %s
      a: apply
     ar: api-resources
     av: api-versions
      c: create
     ci: cluster-info
      d: describe
    dbg: debug -it %s
  dbgno: debug -it --image=alpine "node/%s" -- chroot /host
    doc: explain %s
   docx: explore %s
  drain: drain --delete-emptydir-data --ignore-daemonsets
     ed: edit
   evpo: alpha events --for pod/%s
     ex: exec -i -t
      g: get
   gnoa: get node -L=kubernetes.io/arch,node.kubernetes.io/instance-type,topology.kubernetes.io/region,topology.kubernetes.io/zone,kubernetes.azure.com/agentpool,kubernetes.azure.com/storagetier,kubernetes.azure.com/storageprofile
   gnoe: get node -L=kubernetes.io/arch,node.kubernetes.io/instance-type,topology.kubernetes.io/region,topology.kubernetes.io/zone,eks.amazonaws.com/capacityType
   gnog: get node -L=kubernetes.io/arch,node.kubernetes.io/instance-type,topology.kubernetes.io/region,topology.kubernetes.io/zone,cloud.google.com/gke-nodepool,cloud.google.com/machine-family
   gnok: get node -L=kubernetes.io/arch,node.kubernetes.io/instance-type,topology.kubernetes.io/region,topology.kubernetes.io/zone,eks.amazonaws.com/capacityType,karpenter.sh/capacity-type,karpenter.k8s.aws/instance-cpu,karpenter.k8s.aws/instance-memory
      k: kustomize
     lo: logs
    lof: logs -f
    lop: logs -f -p
      p: proxy
    pex: pexec -it -T %s
   pexc: pexec -it -T %s -c %s
   pexg: pexec -it -T %s --cnsenter-gc
  pexgc: pexec -it -T %s -c %s --cnsenter-gc
     pf: port-forward
    pug: deprecations
     rm: delete
    run: run --rm --restart=Never --image-pull-policy=IfNotPresent -i -t --image=%s
     sc: scale --replicas=%i
     sh: exec -i -t %s -- sh -i -c "exec bash -i || exec sh -i"
   shbr: exec -i -t %s -- apiclient exec -t control enter-admin-container
    shc: exec -i -t %s -c %s -- sh -i -c "exec bash -i || exec sh -i"
      t: top
     tn: top node
    tnp: top-node-pod
     tp: top pod
    ver: version
   wapo: wait --for=condition=Ready pod/%s
      z: fuzzy

Resources
---------
     cm: configmap
     cr: clusterrole.rbac.authorization.k8s.io
    crb: clusterrolebinding.rbac.authorization.k8s.io
    crd: crd.apiextensions.k8s.io
     dc: deploymentconfig.apps.openshift.io
    dep: deployment.apps
     ds: daemonset.apps
     ep: endpoints
     ev: event
     hr: helmrelease
  hrepo: helmrepository
     ic: ingressclass.networking.k8s.io
    ing: ingress.networking.k8s.io
   ingc: ingresscontroller.operator.openshift.io
     is: imagestream.image.openshift.io
     no: nodes
     ns: namespaces
     po: pod -n default
     pr: prometheusrule.monitoring.coreos.com
   prom: prometheus.monitoring.coreos.com
     pv: pv
    pvc: pvc
     rb: rolebinding.rbac.authorization.k8s.io
     ro: role.rbac.authorization.k8s.io
  route: route.route.openshift.io
     rs: replicaset.apps
     sa: serviceaccount
     sc: storageclass.storage.k8s.io
    sec: secret
     sm: servicemonitor.monitoring.coreos.com
    sts: statefulset.apps
    svc: service

Options
-------
          L: -L=%s
        all: --all
         an: --all-namespaces
          c: --container %s
        dry: --dry-run=none -o=yaml
       dryc: --dry-run=client -o=yaml
       dryn: --dry-run=none -o=yaml
       drys: --dry-run=server -o=yaml
          f: -f=%s
      force: --force
          h: --help
          i: -i
          k: -k
          l: -l=%s
          n: --namespace=%s
         nh: --no-headers
        now: --now
          o: -o=%s
         oj: =@ojson
        ojp: =@ojsonpath
        ojs: =@ojson
      ojson: -o=json
  ojsonpath: -o=jsonpath=%s
         on: =@oname
      oname: -o=name
  otemplate: -o=template=%s
       otpl: =@otemplate
         ow: =@owide
      owide: -o=wide
         oy: =@oyaml
      oyaml: -o=yaml
       oyml: =@oyaml
          p: -p
          r: --recursive
        raw: --raw %s
         rm: --rm
         sb: --sort-by=%s
         sl: --show-labels
        sys: --namespace=kube-system
          t: -t
          v: -v=%s
         v5: -v=5
         v6: -v=6
          w: --watch

Prefixes
--------
   -: %s
  -t: time
  -w: watch -n %s --

Suffixes
--------
    +: %s
  +gr: | grep %s

Examples
--------
kgpo                      --> kubectl get pod -n default
kgpon kube-system         --> kubectl get pod -n default --namespace=kube-system
kgpoansl                  --> kubectl get pod -n default --all-namespaces --show-labels
ksysgds                   --> kubectl --namespace=kube-system get daemonset.apps
kgposlan -v=6             --> kubectl get pod -n default --show-labels --all-namespaces -v=6
kafn pod.yaml default     --> kubectl apply -f=pod.yaml --namespace=default
kgns-w3                   --> watch -n 3 -- kubectl get namespaces
kgno- echo                --> echo kubectl get nodes
kgno-+ "echo DRY: [" ]    --> echo DRY: [ kubectl get nodes ]

Please refer to https://github.com/caruccio/autokube for instructions.
```
--------------------

# AutoKubeconfig

Change current kubeconfig as you change directories.

## AutoKubeconfig -- Usage

```sh
$ cd /some/dir
Using kubeconfig: /some/dir/.kubeconfig
$ echo $KUBECONFIG
/some/dir/.kubeconfig
```

You can also use `kubecfg` directly to update $KUBECONFIG env var:

```sh
$ kubecfg ./kubeconfig-dev
Using kubeconfig: /some/dir/.kubeconfig-dev
```

Running `kubecfg` alone prints the current $KUBECONFIG:

```sh
$ kubecfg
/some/dir/.kubeconfig-dev
```

The flag `-u` unsets $KUBECONFIG:

```sh
$ kubecfg -u
Unsetting KUBECONFIG=/some/dir/.kubeconfig-dev
```

--------------------

# ShowKubectl

Print full `kubectl` command before execute it.

## ShowKubectl -- Usage

It's just an small function which replaces `kubectl` and print the whole command to stderr.

Now every `kubectl` command, including aliases and functions, will be printed to stderr before it's executed.

```sh
$ kgno
+ kubectl get nodes
```
