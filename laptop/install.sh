#!/usr/bin/env bash

# Sets up environment

echo "Installing configuration.nix.."
sudo rm /etc/nixos/configuration.nix
sudo ln -s $PWD/configuration.nix /etc/nixos/

echo "Installing settings repositories.."
test -d $HOME/.vim || git clone git@github.com:nthorne/nthorne-vim-environment.git $HOME/.vim
test -d $HOME/.config/nvim || (mkdir $HOME/.config ; ln -s $HOME/.vim $HOME/.config/nvim)
test -f $HOME/.vimrc || ln -s $HOME/.vim/.vimrc $HOME/
test -d $HOME/.zgen || git clone https://github.com/tarjoilija/zgen.git $HOME/.zgen
test -d $HOME/.tmux/plugins/tpm || (mkdir -p $HOME/.tmux/plugins/ && git clone https://github.com/tmux-plugins/tpm.git $HOME/.tmux/plugins/tpm)

test -d $HOME/.zsh || git clone git@github.com:nthorne/nthorne-zsh-environment.git $HOME/.zsh
test -f $HOME/.zprofile || ln -s $HOME/.zsh/.zprofile $HOME/
test -f $HOME/.zshenv || ln -s $HOME/.zsh/.zshenv $HOME/
test -f $HOME/.zshrc || ln -s $HOME/.zsh/.zshrc $HOME/

test -f $HOME/repos || mkdir $HOME/repos
pushd $HOME/repos
test -d nthorne-xmonad-environment || git clone git@github.com:nthorne/nthorne-xmonad-environment.git
test -d $HOME/.xmonad || mkdir $HOME/.xmonad
test -f $HOME/.xmonad/xmonad.hs || ln -s $PWD/nthorne-xmonad-environment/xmonad-nixos.hs $HOME/.xmonad/xmonad.hs

test -d nthorne-tmux-environment || git clone git@github.com:nthorne/nthorne-tmux-environment.git
test -f $HOME/.tmux.conf || ln -s $PWD/nthorne-tmux-environment/.tmux.conf $HOME/
popd

test -f $HOME/.Xresources || ln -s $PWD/.Xresources $HOME/
