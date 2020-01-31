# nixfiles

This repo contains configuration files that I use on my NixOS hosts.

NixOS makes it possible to deploy Linux systems declaratively, and this repo is mostly useful to me when deploying my setup to new machines. Perhaps you will find some inspiration for your own NixOS configurations here!

## Features

- Easy per-host configuration
- Programs declaratively installed through Nix
- Where possible, programs are also configured declaratively through Nix
  - Otherwise symlink dotfiles into home directory
- `fhs` command for running problematic binaries in an FHS environment

## Setup instructions (WSL 2)

```
# Disable sandboxing as it seems to not work in WSL 2
mkdir ~/.config/nix
echo "sandbox = false" > ~/.config/nix/nix.conf

# Install Nix
curl https://nixos.org/nix/install | sh

# Install unstable & unstable-small channels, some packages will be fetched from these
nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable
nix-channel --add https://nixos.org/channels/nixpkgs-unstable unstable-small
nix-channel --update

# Clone the repo to e.g. ~/nixfiles
nix-shell -p git --run "git clone https://github.com/FruitieX/nixfiles.git ~/nixfiles"

# Symlink the nixpkgs config file
ln -s ~/nixfiles/nixpkgs-config.nix ~/.config/nixpkgs/config.nix

# Install the systemToolsEnv
# TODO: why don't channels work without this hack
NIX_PATH=${NIX_PATH:+$NIX_PATH:}unstable=$HOME/.nix-defexpr/channels/unstable:unstable-small=$HOME/.nix-defexpr/channels/unstable-small nix-env -iA nixpkgs.systemToolsEnv
```

## Setup instructions (NixOS)

### First setup

##### Install NixOS

If you haven't done so already, install [NixOS](https://nixos.org) and boot into your
NixOS installation.

Full-disk encryption instructions here: https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134

##### NixOS installation summary (with full disk encryption):

```bash
sudo su
gdisk /dev/sda # partition your disk

# in this example we use:
# - /dev/sda1: EFI partition, make sure it's at least 500 MB
# - /dev/sda2: encrypted root partition

cryptsetup luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 enc-pv

pvcreate /dev/mapper/enc-pv
vgcreate vg /dev/mapper/enc-pv
lvcreate -L 32G -n swap vg
lvcreate -l '100%FREE' -n root vg

mkfs.fat /dev/sda1
mkfs.ext4 -L root /dev/vg/root
mkswap -L swap /dev/vg/swap

mount /dev/vg/root /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/vg/swap

nixos-generate-config --root /mnt
blkid /dev/sda2 # take note of the printed UUID, needed in the next step
vim /mnt/etc/nixos/configuration.nix

# add the following to your configuration.nix or your system won't boot:
#
# boot.initrd.luks.devices = [
#   {
#     name = "root";
#     device = "/dev/disk/by-uuid/<root device uuid>";
#     preLVM = true;
#     allowDiscards = true;
#   }
# ];

nixos-install
reboot

# If everything goes well, skip to the next section.

# Troubleshooting (mounting encrypted partitions from live environment)

cryptsetup luksOpen /dev/sda2 enc-pv
lvchange -a y /dev/vg/swap
lvchange -a y /dev/vg/root
mount /dev/vg/root /mnt
mount /dev/sda1 /mnt/boot
swapon /dev/vg/swap
# now you can fix your configuration and run nixos-install again

# Reinstalling bootloader from live environment
# First follow above troubleshooting steps to mount your encrypted partitions.
for i in dev proc sys; do mount --rbind /$i /mnt/$i; done
NIXOS_INSTALL_BOOTLOADER=1 chroot /mnt \
    /nix/var/nix/profiles/system/bin/switch-to-configuration boot
```

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
# `common.nix` unless you are OK with giving me shell access to your machines... :-)
# Also remember to include boot.initrd.luks.devices if you use full disk encryption!
$EDITOR configuration.nix
```

##### Installing configuration

Run the following command as root:

```sh
NIXOS_CONFIG=/home/username/nixfiles/configuration.nix nixos-rebuild switch
```

If there were no errors, the installation is now complete. If there were
errors, you may want to retry a few times, as e.g. temporary Internet
connection issues can cause the build to fail. Already downloaded packages are fetched
from cache on subsequent tries.

After a successful install, reboot. You should now be able to log-in to GNOME 3.

### Rebuilding the system using configuration from nixfiles

Run this command whenever you change the configuration in nixfiles:

```sh
sudo -E nixos-rebuild switch
```

(note the -E flag which preserves the environment and thus our NIXOS_CONFIG environment variable)
