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