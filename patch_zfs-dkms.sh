#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab:

set -eu

_NAME='Muhaiha'
_EMAIL='archlinux@varum.dk'

ORIGINAL_PACKAGE='zfs-dkms'
MY_PACKAGE='zfs-dkms-any'

rm -rf "${ORIGINAL_PACKAGE}"
rm -rf "${MY_PACKAGE}" 

git clone "https://aur.archlinux.org/${ORIGINAL_PACKAGE}.git"
git clone "ssh://aur.archlinux.org/${MY_PACKAGE}.git"

source "${ORIGINAL_PACKAGE}/PKGBUILD"
original_pkgver="${pkgver}"
original_pkgrel="${pkgrel}"

touch  "${MY_PACKAGE}/PKGBUILD"
source "${MY_PACKAGE}/PKGBUILD"
my_pkgver="${pkgver}"
my_pkgrel="${pkgrel}"


if ! [ "${original_pkgver}" == "${my_pkgver}" -a "${original_pkgrel}" == "${my_pkgrel}" ]; then
  cp "${ORIGINAL_PACKAGE}"/* "${MY_PACKAGE}"

  ### Make it compile on any platform & add patch
  sed -E -e "s/^pkgname=.+/pkgname=${MY_PACKAGE}/" \
         -e '/^[ ]*depends=.+/d' \
         -e "s/^arch=.+/arch=(\'any\')/" \
         -e 's/^conflicts=.+/conflicts=\("'${ORIGINAL_PACKAGE}'" "'${ORIGINAL_PACKAGE%-dkms}'"\)/' \
         -e 's/^provides=.+/provides=\("'${ORIGINAL_PACKAGE}'" "'${ORIGINAL_PACKAGE%-dkms}'"\)/' \
         -e 's/^replaces=.+/replaces=\("'${ORIGINAL_PACKAGE}'"\)/' \
         -e '/^license=/i depends=\("'zfs-utils-any=${pkgver}'" "'dkms'"\)' \
         -e 's/%-dkms/%-dkms-any/g' \
         "${ORIGINAL_PACKAGE}/PKGBUILD" > "${MY_PACKAGE}/PKGBUILD"

  cd "${MY_PACKAGE}"
  makepkg --printsrcinfo > .SRCINFO

  git config user.name  "${_NAME}"
  git config user.email "${_EMAIL}"

  git add --all
  git commit -m 'Update package'
  git push
fi

