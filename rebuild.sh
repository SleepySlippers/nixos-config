#!/bin/sh
set +x
sudo nixos-rebuild switch --flake .#nixos
