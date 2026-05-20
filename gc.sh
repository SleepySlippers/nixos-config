#!/bin/sh
set -x
sudo nix-collect-garbage --delete-older-than 14d

