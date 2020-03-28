#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab:

set -eu

_NAME='Muhaiha'
_EMAIL='archlinux@varum.dk'

ORIGINAL_PACKAGE='zfs-utils'
MY_PACKAGE='zfs-utils-any'

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
         -e "s/^arch=.+/arch=(\'any\')/" \
         -e '/^optdepends=/i conflicts=\("'${ORIGINAL_PACKAGE}'"\)' \
         -e '/^optdepends=/i provides=\("'${ORIGINAL_PACKAGE}'"\)' \
         -e '/^optdepends=/i replaces=\("'${ORIGINAL_PACKAGE}'"\)' \
         -e '/^[ ]+\.\/configure/i \    ./autogen.sh\n' \
         "${ORIGINAL_PACKAGE}/PKGBUILD" > "${MY_PACKAGE}/PKGBUILD"

  cd "${MY_PACKAGE}"
  makepkg --printsrcinfo > .SRCINFO

  git config user.name  "${_NAME}"
  git config user.email "${_EMAIL}"

  git add --all
  git commit -m 'Update package'
  git push
fi

