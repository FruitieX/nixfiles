# FruitieX' nixfiles

NixOS makes it possible to build system configurations declaratively.

Here are my NixOS configuration files which can be used to build identical configurations as what I run on my hosts.

## Features

- Easy per-host configuration
- `fhs` command for running third party binaries in an FHS environment
- System-wide package lists, partly shared with FHS environments
- Dotfiles symlinked to home directory
- And more...

## TODO

- Manage KDE system settings
- Dotfiles in Nix store

## Setup instructions

Note: All steps except last one only need to be ran once (when performing
first setup).

### Install NixOS

If you haven't done so already, install [NixOS](https://nixos.org) and boot into your
NixOS installation.

### Fetching the repo

```sh
# Clone the repo to e.g. ~/nixfiles, then cd to it:
git clone https://github.com/FruitieX/nixfiles.git ~/nixfiles
cd ~/nixfiles
```

### Per-host configuration

```sh
# Name this host "my-hostname" by writing the hostname string to hostname.nix
# Note that hostname.nix is ignored by git
echo \"my-hostname\" > hostname.nix

# Create per-host configuration directory for my-hostname
mkdir hosts/my-hostname

# Copy over the hardware-configuration.nix that the NixOS installer generated
# for this host
cp /etc/nixos/hardware-configuration.nix hosts/my-hostname/

# Write your per-host configuration, use e.g. satsuma's (my home server)
# default.nix as an example:
cp hosts/satsuma/default.nix hosts/my-hostname/default.nix
```

### Installing configuration

```sh
sudo mv /etc/nixos /etc/nixos-old
sudo ln -s ~/nixfiles /etc/nixos
```

### Rebuilding the system using configuration from nixfiles

Run this command whenever you change the configuration in ~/nixfiles

```sh
sudo nixos-rebuild switch
```
