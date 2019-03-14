Installation
------------

Clone all dot-repos (follow the respective README):

    $ mkdir repos
    $ cd repos
    $ git clone https://github.com/nthorne-nixos-environment
    $ git clone https://github.com/nthorne-tmux-environment
    $ git clone https://github.com/nthorne-vim-environment
    $ git clone https://github.com/nthorne-xmonad-environment
    $ git clone https://github.com/nthorne-zsh-environment

Generate a hash for the proxy, and update proxy.nix, according to comments.

Symlink all the files under `dotfiles/` into the proper places.

Re-create the samba credentials file (`/etc/nixos/smb-secrets`).

Set up the cronjob for my backup script.


Scripted
--------

*WARNING:* This is untested, but hey - what could go wrong?!
