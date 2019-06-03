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

function error()
{
  echo "Error: $@" >&2
  exit 1
}

if [[ $(basename ${PWD}) != "work" ]]
then
  error "Script needs to be executed from the work folder, not $(basename ${PWD})"
fi

test -d "${HOME}/repos" || error "Missing folder ${HOME}/repos"

echo "Installing scripts.."
mkdir $HOME/bin
ln -s ${PWD}/scripts/*.sh ${HOME}/bin/
ln -s ${PWD}/scripts/*.xdo ${HOME}/bin/

test -d ${HOME}/.ssh && error "${HOME}/.ssh exists. Bailing out."
echo "Installing dotfiles"
ln -s ${PWD}/dotfiles/.ssh ${HOME}/
ln -s ${PWD}/dotfiles/.tmuxinator ${HOME}/
ln -s ${PWD}/dotfiles/.gitconfig ${HOME}/
ln -s ${PWD}/dotfiles/.minirc.usb* ${HOME}/
ln -s ${PWD}/dotfiles/.Xresources ${HOME}/
mkdir -p ${HOME}/.lnav/formats/
ln -s ${PWD}/dotfiles/lnav ${HOME}/.lnav/formats/own

echo "Cloning environment repos if needed.."
pushd ${HOME}/repos
test -d nthorne-tmux-environment   || git clone https://github.com/nthorne/nthorne-tmux-environment
test -d nthorne-vim-environment    || git clone https://github.com/nthorne/nthorne-vim-environment
test -d nthorne-xmonad-environment || git clone https://github.com/nthorne/nthorne-xmonad-environment
test -d nthorne-zsh-environment    || git clone https://github.com/nthorne/nthorne-zsh-environment
popd

echo "Installing environments"
pushd ${HOME}/repos/nthorne-tmux-environment
./install-work.sh
popd
pushd ${HOME}/repos/nthorne-vim-environment
./install-work.sh
popd
pushd ${HOME}/repos/nthorne-xmonad-environment
./install-work.sh
popd
