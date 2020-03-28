#!/usr/bin/env bash

set -eu

./patch_zfs-dkms.sh
./patch_zfs-utils.sh
./patch_mkinitcpio-sd-zfs.sh

