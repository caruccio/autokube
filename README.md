# AutoKube Tools

Here lies my *swiss army knife* of kubernetes tools I use on a daily-basis.

> Please not all tools are built for BASH, SH and ZSH, but may be easy enough to port to other shells.
> Feel free to send PRs.

```sh
git clone https://github.com/caruccio/autokube
cd autokube
make
```

- [Install](#install)
- [AutoKubectl](#autokubectl): mnemonic kubectl command generator.
- [AutoKubeconfig](#autokubeconfig): switch KUBECONFIG file as you `cd` into a new directory.
- [ShowKubectl](#showkubectl): print final kubectl command before executing it.

# Install

To install system-wide:

```
sudo make install
```

Files will be installed into `/etc/profile.d`. Just start a new shell section to use it.

To install for the current user only:

```
make install-user
```

Files are `source`ed from the current directory (where you cloned it) on your RC file (`~/.bashrc`, `~/.zshrc` or `~/.profile`).
Either start a new shell session or source it (ex: `source ~/.bashrc`)

# Use without install

You can try it without installing any file, just source it from thew public repo:

> Commands are separated for your convenience.

```sh
eval "$(curl -sL https://github.com/caruccio/autokube/raw/main/autokubectl.sh)"
```

```sh
eval "$(curl -sL https://github.com/caruccio/autokube/raw/main/showkubectl.sh)"
```

```sh
eval "$(curl -sL https://github.com/caruccio/autokube/raw/main/autokubeconfig.sh)"
```

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
k -> [verb] -> [resource] -> [option] -> [prepend[N]] -> [append]
```

There is no order within each class of mnemonics.

## AutoKubectl -- Append and prepend commands

You can prepend and append (with |) commands. Mnemonic starting with `-` are prepended to command, and those starting with `+` are appended.

```sh
kgpoojn-w1+gr kube-system apiserver
```

Becomes:
```
watch -n 1 -- kubectl get pods -o=json --namespace="kube-system" | grep "apiserver"
+-----------+         +-+ +--+ +-----+ +-----------------------+ +----------------+
      |                |    |     |              |                       |
  [prepend + N]     [verb]  |  [option]    [options + $1]             [append]
                            |
                       [resources]
```

## AutoKubectl -- How it works

It defines the special bash function `command_not_found_handle` (command_not_found_handler for zsh) to intercept commands not found.
The function walks char-by-char of the first parameter (ths command itself), searching for the longest mnemonic sequence on a lookup-table (just some associative arrays),
translating one or more characters into kubectl verbs, resources and options.

You can see all available mnemonics by executing `kH` (H stands for help).

The lookup-tables can be expanded or modified with your custom mappings.

```sh
source /etc/profile.d/autokubectl.sh     # only if not properly installed in /etc/profile.d/

autokube_command_not_found_handle_map_verb[K]='krew'
autokube_command_not_found_handle_map_verb[Ki]='krew install "%s"'    ## each "%s" is replaced with positional parameters afther the command, like in $1 $2 $N...
autokube_command_not_found_handle_map_verb[Kl]='krew list'
autokube_command_not_found_handle_map_verb[D]='deprecations'          ## https://kubepug.xyz/
```

Now you can use your own mnemonics.

```sh
$ kKi deprecations     --> kubectl krew install deprecations
$ kD                   --> kubectl deprecations
$ kDv debug            --> kubectl deprecations -v=debug
```

If var `AUTOKUBECTL_DRYRUN=true` no command is executed, and the resulting expansion is shown in stdout:

```sh
$ AUTOKUBECTL_DRYRUN=true
$ kgevwnvoj default 3
kubectl get event -w -n="default" -v="3" -o=json
```

To delete all mnemonics execute `kF`. To restore it just `source /path/to/autokubectl.sh`.

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
Available mnemonics

Verbs
-----
a      apply --recursive -f "%s"
ar     api-resources
av     api-versions
c      create
d      describe
dbg    debug -it "%s"
dbgno  debug -it --image=alpine "node/%s" -- chroot /host
doc    explain "%s"
docx   explore "%s"
drain  drain --delete-emptydir-data --ignore-daemonsets
ed     edit
ex     exec -i -t
g      get
gnok   get node -L=kubernetes.io/arch,eks.amazonaws.com/capacityType,karpenter.sh/capacity-type,karpenter.k8s.aws/instance-cpu,karpenter.k8s.aws/instance-memory,node.kubernetes.io/instance-type
gnoz   get node -L=kubernetes.io/arch,beta.kubernetes.io/instance-type
H      HELP
k      kustomize
K      krew
Ki     krew install "%s"
lo     logs
lof    logs -f
lop    logs -f -p
p      proxy
pf     port-forward
rm     delete
run    run --rm --restart=Never --image-pull-policy=IfNotPresent -i -t --image="%s"
sh     exec -i -t "%s" -- sh -i -c "bash -i || exec sh -i"
shac   exec -i -t "%s" -- apiclient exec -t control enter-admin-container
shbr   exec -i -t "%s" -- apiclient exec -t control enter-admin-container
t      top
tn     top node
tnp    top-node-pod
tp     top pod
ver    version
z      fuzzy

Resources
---------
cm     configmap
cr     clusterrole
crb    clusterrolebinding
crd    clusterrolebinding
dc     deploymentconfig
dep    deployment
ds     daemonset
ev     event
ing    ingress
is     imagestream
no     nodes
ns     namespaces
po     pods
pv     pv
pvc    pvc
rb     rolebinding
ro     role
route  route
sa     serviceaccount
sec    secret
sts    statefulset
svc    service

Options
-------
A          --all
all        --all-namespaces
dry        --dry-run=none -o=yaml
dryc       --dry-run=client -o=yaml
dryn       --dry-run=none -o=yaml
drys       --dry-run=server -o=yaml
f          --recursive -f="%s"
force      --force
h          --help
i          -i
k          -k
l          -l="%s"
L          -L="%s"
n          --namespace="%s"
nh         --no-headers
now        --now
o          -o="%s"
oj         -o=json
ojp        -o=jsonpath="%s"
ojs        -o=json
ojson      -o=json
ojsonpath  -o=jsonpath="%s"
on         -o=name
oname      -o=name
otemplate  -o=template="%s"
otpl       -o=template="%s"
ow         -o=wide
owide      -o=wide
oy         -o=yaml
oyaml      -o=yaml
oyml       -o=yaml
p          -p
raw        --raw "%s"
rm         --rm
sb         --sort-by="%s"
sl         --show-labels
sys        --namespace=kube-system
t          -t
v          -v="%s"
w          --watch

Prepends
--------
-   %s
-t  time
-w  watch -n %i --

Appends
--------
+    | %s
+gr  | grep "%s"

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
