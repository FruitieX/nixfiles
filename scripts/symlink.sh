#!/usr/bin/env bash

USER=$1

# Symlink all the files in $1 to $2, $1 needs to be an absolute path
linkdir() {
  for f in $(find $1 -maxdepth 1 -type f -printf '%P\n'); do
  ln -s -f -v $1/$f $2/$f;
  chown -h $USER:users $2/$f
  done
}

# Recursively symlink all the files in $1 to $2
reclink () {
  linkdir $1 $2
  for d in $(find $1 -type d -printf '%P\n'); do
  mkdir -p -v $2/$d;
  chown $USER:users $2/$d
  linkdir $1/$d $2/$d;
  done
};

reclink /etc/nixos/home /home
unset -f linkdir
unset -f reclink
