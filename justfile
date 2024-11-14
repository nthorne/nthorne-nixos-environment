build:
  sudo nixos-rebuild build --flake .#  

switch:
  sudo nixos-rebuild switch --flake .# && rm result 

update:
  nix flake update --commit-lock-file .#

push:
  git push
