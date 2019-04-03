#!/usr/bin/env bash

# vim: filetype=sh

# Set IFS explicitly to space-tab-newline to avoid tampering
IFS=' 	
'


NAME=
# Make sure that we're not on NixOS; if so, avoid tampering with PATH
if [[ -f /etc/os-release ]]
then
  . /etc/os-release
fi

if [[ "NixOS" != "$NAME" ]]
then
  # If found, use getconf to constructing a reasonable PATH, otherwise
  # we set it manually.
  if [[ -x /usr/bin/getconf ]]
  then
    PATH=$(/usr/bin/getconf PATH)
  else
    PATH=/bin:/usr/bin:/usr/local/bin
  fi
fi


readonly BACKUP_FILE="backup-$(date '+%u')"
readonly BACKUP_FOLDER="${HOME}/tmp/backups/backup-${BACKUP_FILE}"


function usage()
{
  cat <<Usage_Heredoc
Usage: $(basename $0) [OPTIONS]

Create an encrypted backup of essential files.

Where valid OPTIONS are:
  -h, --help  display usage

Usage_Heredoc
}

function error()
{
  echo "Error: $@" >&2
  exit 1
}

function parse_options()
{
  while (($#))
  do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "Unknown option: $1. Try $(basename $0) -h for options."
        ;;
    esac

    shift
  done
}


parse_options "$@"

echo "Creating backup folder ${BACKUP_FOLDER}.."

test -f ${HOME}/backup_passphrase || error "${HOME}/backup_passphrase: no such file"

test -d ${BACKUP_FOLDER} && rm -rf ${BACKUP_FOLDER}
mkdir -p ${BACKUP_FOLDER}

pushd ${BACKUP_FOLDER}

set -x
cp -r ${HOME}/repos/nthorne-nixos-environment .
cp -r ${HOME}/repos/nthorne-vim-environment .
cp -r ${HOME}/repos/nthorne-zsh-environment .
cp -r ${HOME}/repos/dev-cookbook .
cp -r ${HOME}/.mozilla .
cp -r ${HOME}/.ssh .
cp -r ${HOME}/.vim-bookmarks .
cp -r ${HOME}/.zshhistory .
cp -r ${HOME}/Downloads/tiddlywikis .
cp -r ${HOME}/Documents .

crontab -l > crontab.nthorne

cd ..

tar czvf ${BACKUP_FILE}.tar.gz ${BACKUP_FOLDER}
cat ${HOME}/backup_passphrase | gpg --batch --passphrase-fd 0 -c ${BACKUP_FILE}.tar.gz
scp ${BACKUP_FILE}.tar.gz.gpg as:backups/
cp ${BACKUP_FILE}.tar.gz.gpg essentials.tar.gz.gpg
rm ${BACKUP_FILE}*
popd

echo "Removing backup folder ${BACKUP_FOLDER}"
rm -rf ${BACKUP_FOLDER}
