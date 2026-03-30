# komar-os

A NixOS-based terminal-oriented declarative operating system AKA dotfiles.

## Description

This repository contains my entire NixOS configuration used on a few machines, for work and fun.

### NixOS & Home Manager

Some configuration files are declared using Home Manager which is used in standalone mode. This
means that independently of rebuilding the NixOS system, it is necessary to also rebuild the Home
Manager configuration. This is caused by the fact that not all of my machines use NixOS. That's also
why I tend to keep as much of the configuration in Home Manager instead of NixOS as possible.

Some core components (like neovim and tmux config) are separated to other repositories as flakes
containing Home Manager modules and can be used standalone. Possibly the same fate will meet more
core components in the future.

### Legacy dotfiles

Unfortunately some configuration files are not managed by Home Manager (yet) and need to be linked
to the home directory on top of rebuilding Home Manager configuration. I am working on converting
all configuration in this repository to Home Manager.

As long as some configuration files remain not managed by Home Manager, it is recommended to use the
provided [populate_links.sh](https://github.com/komar007/komar-os/blob/main/populate_links.sh) to
link all the legacy dotfiles to the home directory.

## Contributing

This repository was created based on too many other dotfile repos, gists and articles and blog posts
to even remember or list here, so I hope it can be of use to someone else.

I don't think anyone would like to contribute to someone else's dotfiles, but you can look around
for configuration ideas or ask me a questions directly on github instead.

Found a way things can be improved? Create an issue or contact me directly, as well.

I don't promise any issues will be resolved, but feedback is welcome anyway!

## Legacy komar-desktop

This repository used to be called `komar-desktop`, but it has been renamed because its name was too
specific and too misleading.

After about 9 months of development of my NixOS configuration, it was finally merged here and
development continues on branch [`main`](https://github.com/komar007/komar-os/tree/main).

The development of the legacy branch [`master`](https://github.com/komar007/komar-os/tree/master)
ceased in May 2025. Some disused config files no longer available on
[`main`](https://github.com/komar007/komar-os/tree/main) (mutt, emacs, and a few others) can still
be found there.
