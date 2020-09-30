Run these steps from within an existing Linux installation (such as Ubuntu on WSL):

- Install Nix: https://nixos.org/download.html#nix-quick-install
- `git clone https://github.com/Trundle/NixOS-WSL`
- `cd NixOS-WSL`
- `$EDITOR configuration.nix` and:
  - Add `extraGroups = [ "wheel" ];` to the `users.users.${defaultUser} = { ... }` section
  - Change the `defaultUser` variable to whatever you want
- `nix-build -A system -A config.system.build.tarball ./nixos.nix`
- `mkdir "/mnt/c/Users/[Windows username]/NixOS"`
- `cp result-2/tarball/nixos-system-x86_64-linux.tar.gz "/mnt/c/Users/[Windows username]/NixOS/"`

Open up Windows PowerShell and run:

- `wsl --import NixOS .\NixOS\ .\NixOS\nixos-system-x86_64-linux.tar.gz --version 2`
- `wsl -s NixOS`
- `wsl`

You will be dropped into a very primitive `sh` shell, from here you need to run this once:

- `/nix/var/nix/profiles/system/activate`

You should be able to safely ignore warnings about locales.

Exit and restart WSL and you should be greeted with a much fancier bash prompt.

TODO: wslpath binary, vscode remote fix script
