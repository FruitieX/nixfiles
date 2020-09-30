```bash
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
