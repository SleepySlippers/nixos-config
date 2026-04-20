#!/bin/sh
set +x
nixos-option --flake .#nixos $@
