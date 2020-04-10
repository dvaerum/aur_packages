#!/usr/bin/env bash
# ex: set tabstop=8 softtabstop=0 expandtab shiftwidth=2 smarttab:

set -eu

_NAME='Muhaiha'
_EMAIL='archlinux@varum.dk'

_POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -f|--force)
    _FORCE=1
    shift # past argument
    ;;
    -t|--test)
    _TEST=1
    shift # past argument
    ;;
    *)    # unknown option
    _POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${_POSITIONAL[@]}" # restore positional parameters

function check_for_new_version() {
  rm -rf "${ORIGINAL_PACKAGE}"
  rm -rf "${MY_PACKAGE}"

  git clone "https://aur.archlinux.org/${ORIGINAL_PACKAGE}.git"
  if [ ${_TEST:-0} -ne 1 ]; then
    git clone "ssh://aur.archlinux.org/${MY_PACKAGE}.git" "${MY_PACKAGE}"
  else
    rsync -a --delete "${ORIGINAL_PACKAGE}/." "${MY_PACKAGE}"
  fi

  source "${ORIGINAL_PACKAGE}/PKGBUILD"
  original_pkgver="${pkgver}"
  original_pkgrel="${pkgrel}"
  unset pkgver
  unset pkgrel

  touch  "${MY_PACKAGE}/PKGBUILD"
  source "${MY_PACKAGE}/PKGBUILD"
  my_pkgver="${pkgver:-}"
  my_pkgrel="${pkgrel:-}"

  if ! [ "${original_pkgver}" == "${my_pkgver}" -a "${original_pkgrel}" == "${my_pkgrel}"  ] || [ ${_FORCE:-0} -eq 1 ]; then
    echo "Starter patching of ${ORIGINAL_PACKAGE}..."

    ### This function 'patch_func' is specified in the patch-script there source this file
    patch_func
    echo "Patching finished."

    cd "${MY_PACKAGE}"
    echo "Creates the .SRCINFO file."
    makepkg --printsrcinfo > .SRCINFO

    if [ ${_TEST:-0} -ne 1 ]; then
      echo "Commit and push the new version to the AUR"
      git config user.name  "${_NAME}"
      git config user.email "${_EMAIL}"

      git add --all
      git commit -m 'Update package'
      git push
    fi
  else
    echo "There is no new version of ${ORIGINAL_PACKAGE}"
  fi
}
