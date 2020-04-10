#!/usr/bin/env bash

set -eu

for patch_script in $(ls patch_*.sh); do
  "./${patch_script}"
done
