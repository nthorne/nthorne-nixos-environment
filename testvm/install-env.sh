#!/usr/bin/env bash

function install-vim-environment()
{
  echo "** Installing vim environment.."
  [[ ! -d $HOME/.vim ]] && git clone --recursive https://github.com/nthorne/nthorne-vim-environment $HOME/.vim
  [[ ! -L $HOME/.vimrc ]] && ln -s $HOME/.vim/.vimrc $HOME
  [[ ! -d $HOME/.config ]] && mkdir $HOME/.config
  [[ ! -L $HOME/.config/nvim ]] && ln -s $HOME/.vim $HOME/.config/nvim
}

function install-zsh-environment()
{
  echo "** Installing zsh environment.."
  [[ ! -d $HOME/.zsh ]] && git clone --recursive https://github.com/nthorne/nthorne-zsh-environment $HOME/.zsh
  [[ ! -L $HOME/.zprofile ]] && ln -s $HOME/.zsh/.zprofile $HOME/
  [[ ! -L $HOME/.zshenv ]] && ln -s $HOME/.zsh/.zshenv $HOME/
  [[ ! -L $HOME/.zshrc ]] && ln -s $HOME/.zsh/.zshrc $HOME/
  [[ ! -d $HOME/.zgen ]] && git clone --recursive https://github.com/tarjoilija/zgen.git $HOME/.zgen
}

function install-xmonad-environment()
{
  echo "** Installing xmonad environment.."
  [[ ! -d $HOME/repos ]] && mkdir $HOME/repos
  [[ ! -d $HOME/repos/nthorne-xmonad-environment ]] && git clone --recursive https://github.com/nthorne/nthorne-xmonad-environment $HOME/repos/nthorne-xmonad-environment
  [[ ! -d $HOME/.xmonad ]] && mkdir $HOME/.xmonad
  [[ ! -L $HOME/.xmonad/xmonad.hs ]] && ln -s $HOME/repos/nthorne-xmonad-environment/xmonad-home.hs $HOME/.xmonad/xmonad.hs
  [[ ! -x $HOME/.xmonad/xmonad-$(uname -m)-linux ]] && (cd $HOME/.xmonad && xmonad --recompile && xmonad --replace)
}

function install-tmux-environment()
{
  echo "** Installing tmux environment.."
  [[ ! -d $HOME/repos ]] && mkdir $HOME/repos
  [[ ! -d $HOME/repos/nthorne-tmux-environment ]] && git clone --recursive https://github.com/nthorne/nthorne-tmux-environment $HOME/repos/nthorne-tmux-environment
  [[ ! -L $HOME/.tmux.conf ]] && ln -s $HOME/repos/nthorne-tmux-environment/.tmux.conf $HOME/
}

function install-extra-dotfiles()
{
  echo "** Installing extra dotfiles.."
  [[ ! -f $HOME/.conkyrc ]] && cp dotfiles/.conkyrc ~/
  [[ ! -f $HOME/.Xresources ]] && cp dotfiles/.Xresources ~/
)

install-vim-environment
install-zsh-environment
install-xmonad-environment
install-tmux-environment

install-extra-dotfiles
