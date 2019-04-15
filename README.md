# FruitieX' nixfiles

NixOS makes it possible to build system configurations declaratively.

Here are my NixOS configuration files which can be used to build identical configurations as what I run on my hosts.

## Features

- Easy per-host configuration
- System-wide package lists, with separate client / server configs
- Most programs configured declaratively through Nix
- Problematic programs have their dotfiles symlinked into user's home directory
- `fhs` command for running third party binaries in an FHS environment

## Setup instructions

Note: All steps except last one only need to be ran once (when performing
first setup).

### Prerequisites

##### Install NixOS

If you haven't done so already, install [NixOS](https://nixos.org) and boot into your
NixOS installation.

##### Preparing the environment

Run the following commands as root:

```
# Install unstable & unstable-small channels, some packages will be fetched from these
nix-channel --add https://nixos.org/channels/nixos-unstable unstable
nix-channel --add https://nixos.org/channels/nixos-unstable-small unstable-small
nix-channel --update

# Create unprivileged user and set their password
useradd -m username
passwd username
```

##### Fetching the repo and editing configuration

Log in as your newly created user and run the following commands:

```sh
# Clone the repo to e.g. ~/nixfiles, then cd to it:
nix-shell -p git --run "git clone https://github.com/FruitieX/nixfiles.git ~/nixfiles"
cd ~/nixfiles

# Name this host "my-hostname" by writing the hostname string to hostname.nix
echo \"my-hostname\" > hostname.nix

# Create per-host configuration directory for my-hostname
mkdir hosts/my-hostname

# Copy over the hardware-configuration.nix that the NixOS installer generated
# for this host
cp /etc/nixos/hardware-configuration.nix hosts/my-hostname/

# Write your per-host configuration, use e.g. satsuma's (my home server)
# default.nix as an example:
cp hosts/satsuma/default.nix hosts/my-hostname/default.nix

# Read through and edit the configs to your liking. `configuration.nix` is a
# good place to start, as everything else is imported from here. You should at
# least change the user variable, and probably also remove my SSH pubkey from
# `common.nix`... :-)
$EDITOR configuration.nix
```

### Installing configuration

Run the following command as root:

```sh
NIXOS_CONFIG=/home/username/nixfiles nixos-rebuild switch
```

If there were no errors, the installation is now complete. If there were
errors, you may want to retry a few times, as e.g. temporary Internet
connection issues can fail the build. Already downloaded packages are fetched
from cache.

### Rebuilding the system using configuration from nixfiles

Run this command whenever you change the configuration in nixfiles:

```sh
sudo nixos-rebuild switch
```
