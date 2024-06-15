# AutoKube Tools

Here lies my *swiss army knife* of kubernetes tools I use on a daily-basis.

I'm assuming this repo is cloned to `/opt/autokube`, but you can clone it somewhere.

```sh
git clone https://github.com/caruccio/autokube
sudo mv autokube /opt/
```

## AutoKubectl

**Mnemonic kubectl commands**

Sorry, bash-only for now.

### AutoKubectl -- TL;DR;

```sh
# Install
echo 'source ~/autokube/autokubectl.sh' >> ~/.bashrc
source ~/.bashrc

# Execute:
kgwponv default 3

# And it will run:
kubectl get -w pod -n="default" -v="3"
```

### AutoKubectl -- Usage

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

Here, each mnemonic becomes a kubectl parameter.

```
k  --> kubectl (required)
g  --> get
ev --> event
w  --> -w
n  --> namespace=$1
v  --> -v=$2
oj --> -o=json
```

The order doesn't matter (much).

It works by searching for the longest mnemonic sequence on a lookup-table (just some associative arrays), translating characters (or a sequence of characters) into kubectl verbs, resources and options.

You can see all available mnemonics by executing `kH` (H stands for help).

The lookup-tables can be expanded or modified with your custom mappings.

```sh
source /etc/profile.d/autokubectl.sh     # only if not properly installed in /etc/profile.d/

autokube_command_not_found_handle_map_verb[K]='krew'
autokube_command_not_found_handle_map_verb[Ki]='krew install "%s"'    ## each "%s" is replaced with positional parameters afther the command, like in $1 $2 $N...
autokube_command_not_found_handle_map_verb[Kl]='krew list'
autokube_command_not_found_handle_map_verb[D]='deprecations'
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

### AutoKubectl -- Install

**Disclaimer**

This method may conflicts with other tools that install a "command not found" handler function.
For example, Fedora-like distros often comes with package [PackageKit-command-not-found](https://fedoraproject.org/wiki/Features/PackageKitCommandNotFound) installed.
This packages provides the file `/etc/profile.d/PackageKit.sh` with a single function `command_not_found_handle`, which is called by `bash` when a command you typed is not found.
That is how it can suggest speelling corretions or even packages for that uninstalled command in your system.

You can see [this sections of bash's manual](https://www.gnu.org/software/bash/manual/bash.html#Command-Search-and-Execution) for details.

The problem is that files from `/etc/profile.d` are `source`ed on boot, with no garantees that our file will overwrite PackageKit-command-not-found's function.

That said, you can only have one "command not found" function handler (for now). Thus, either you uninstall PackageKit-command-not-found or source autokubectl.sh from your .bashrc:


Either source it from your .bashrc:

```sh
echo "source /opt/autokubectl.sh" >> ~/.bashrc
```

Or install it system-wide (see explaning above):

```sh
sudo cp /opt/autokube/autokubectl.sh /etc/profile.d/
```

Restart your shell/terminal and that's it.

### AutoKubectl -- Caveats

There are problems with this method? Of course there are!! Who do you think I'm?! Dennis Ritchie?!

Sometimes you will face ambiguity, but I can live with that... Fell free to fix and send me a PR.

For example `kgno`: is this `kubectl get node` or `kubect get -n=$1 -o=$2`?

Turns out the longest mnemonic matches first, thus `no` (2 chars) will match as `node`, not `n` (1 char) + `o` (1 char).

### AutoKubectl -- Help

Use the command `kH` to show help.

```sh
$ kH
Available mnemonics

Verbs
-----
a:      apply
c:      create
d:      describe
dbg:    debug -it %s
dbgno:  debug -it --image=alpine node/%s -- chroot /host
ex:     exec -i -t
F:      FLUSH
g:      get
gnok:   get node -L=kubernetes.io/arch,eks.amazonaws.com/capacityType,karpenter.sh/capacity-type,karpenter.k8s.aws/instance-cpu,karpenter.k8s.aws/instance-memory
gnoz:   get node -L=kubernetes.io/arch,beta.kubernetes.io/instance-type
H:      HELP
help:   --help
K:      krew
Ki:     krew install "%s"
lo:     logs
lof:    logs -f
rm:     delete
run:    run --image="%s"
sh:     exec -i -t "%s" -- sh -i -c "bash -i                                                                                                                         exec sh -i"

Resources
---------
cm:   configmap
cr:   clusterrole
crb:  clusterrolebinding
dc:   deploymentconfig
dep:  deployment
ev:   event
ing:  ingress
is:   imagestream
no:   node
po:   pod
pv:   pv
pvc:  pvc
r:    role
rb:   rolebinding
ro:   route
sa:   serviceaccount
sec:  secret
sts:  statefulset
svc:  service

Options
-------
A:          --all-namespaces
all:        --all
dry:        --dry-run=none -o yaml
dryc:       --dry-run=client -o yaml
dryn:       --dry-run=none -o yaml
drys:       --dry-run=server -o yaml
f:          -f "%s"
force:      --force
it:         -i -t
l:          -l "%s"
n:          -n="%s"
nh:         --no-headers
now:        --now
o:          -o="%s"
oj:         -o=json
ojp:        -o=jsonpath
ojs:        -o=json
ojson:      -o=json
ojsonpath:  -o=jsonpath="%s"
on:         -o=name
oname:      -o=name
otemplate:  -o=template="%s"
otpl:       -o=template="%s"
ow:         -o=wide
owide:      -o=wide
oy:         -o=yaml
oyaml:      -o=yaml
oyml:       -o=yaml
rm:         --rm
sb:         --sort-by="%s"
sl:         --show-labels
sys:        -n=kube-system
v:          -v="%s"
w:          -w

Watches
-------
W:  watch -n %i --

Please refer to https://github.com/caruccio/autokube for instructions.
```

## AutoKubeconfig

Change current kubeconfig as you change directories.

### AutoKubeconfig -- Usage

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

### AutoKubeconfig -- Install

```sh

Either source it from your .bashrc:

```sh
echo "source /opt/autokubeconfig.sh" >> ~/.bashrc
```

Or install globally (see explaning above):

```sh
sudo cp /opt/autokube/autokubeconfig.sh /etc/profile.d/
```

Restart your shell/terminal and that's it.

## ShowKubectl

Print full `kubectl` command before execute it

### ShowKubectl -- Usage/Install

It's just an small function which replaces `kubectl` and print the whole command to stderr.

```sh
echo "source /opt/showkubectl.sh" >> ~/.bashrc
source ~/.bashrc
```

Now every `kubectl` command, including aliases and functions, will be printed to stderr before it's executed.

```sh
$ kgno
+ kubectl get nodes
```
