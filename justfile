default: build diff

build:
  sudo nixos-rebuild build --flake .#  

diff:
  nvd diff /nix/var/nix/profiles/system result

switch:
  sudo nixos-rebuild switch --flake .# && rm result 

update:
  nix flake update --commit-lock-file --flake .#

push:
  git push
