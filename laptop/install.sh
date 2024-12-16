#!/usr/bin/env bash

# Sets up environment

echo "Installing configuration.nix.."
test -L /etc/nixos/configuration.nix || (sudo rm /etc/nixos/configuration.nix ; sudo ln -s $PWD/configuration.nix /etc/nixos/)
test -L /etc/nixos/adaptation.nix || (sudo rm /etc/nixos/adaptation.nix ; sudo ln -s $PWD/adaptation.nix /etc/nixos/)
test -L /etc/nixos/private.nix || (sudo rm /etc/nixos/private.nix ; sudo ln -s $PWD/private.nix /etc/nixos/)

echo "Installing settings repositories.."
test -d $HOME/.zgen || git clone https://github.com/tarjoilija/zgen.git $HOME/.zgen

test -d $HOME/.zsh || git clone git@github.com:nthorne/nthorne-zsh-environment.git $HOME/.zsh
test -f $HOME/.zprofile || ln -s $HOME/.zsh/.zprofile $HOME/
test -f $HOME/.zshenv || ln -s $HOME/.zsh/.zshenv $HOME/
test -f $HOME/.zshrc || ln -s $HOME/.zsh/.zshrc $HOME/

test -d $HOME/repos || mkdir $HOME/repos
pushd $HOME/repos
test -d nthorne-xmonad-environment || git clone git@github.com:nthorne/nthorne-xmonad-environment.git
test -d $HOME/.xmonad || mkdir $HOME/.xmonad
test -f $HOME/.xmonad/xmonad.hs || ln -s $PWD/nthorne-xmonad-environment/xmonad-nixos.hs $HOME/.xmonad/xmonad.hs

popd

test -f $HOME/.Xresources || ln -s $PWD/.Xresources $HOME/
test -f $HOME/.conkyrc || ln -s $PWD/.conkyrc $HOME/
test -f $HOME/.gitconfig || ln -s $PWD/.gitconfig $HOME/
test -f $HOME/.vimperatorrc || ln -s $PWD/.vimperatorrc $HOME/
