#!/usr/bin/env bash

# Run this script after vscode has finished downloading and installing its
# server binaries in $HOME/.vscode-server* and is now unable to run the node
# binary ($HOME/.vscode-server*/bin/*/node: No such file or directory)

NODE_PACKAGE=nodejs-12_x
NODE_PATH=$(nix-build '<nixpkgs>' --no-build-output -A $NODE_PACKAGE)/bin/node
DIRS=$HOME/.vscode-server*/bin/*

for dir in $DIRS; do
  cd $dir
  ln -sf $NODE_PATH
done
