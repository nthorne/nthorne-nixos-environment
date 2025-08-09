default: build diff

build:
  sudo nixos-rebuild build --flake .#  

diff:
  nvd diff /nix/var/nix/profiles/system result

assert_git_clean:
  test -z "$(git status --porcelain)"

tag_generation:
  #!/usr/bin/env bash
  set -euo pipefail
  generation=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | fgrep current | awk '{print $1}')
  host=$(hostname)
  tag="${host}-${generation}"
  if ! git tag | grep -q "${tag}"; then
    git tag "${tag}"
  fi

switch: assert_git_clean && tag_generation
  sudo nixos-rebuild switch --flake .# && rm -f result 

test:
  sudo nixos-rebuild test --flake .# && rm result

update:
  nix flake update --commit-lock-file --flake .#

push:
  git push

update_hex_containers:
  #!/usr/bin/env bash
  sudo systemctl stop \
    podman-openwebui.service \
    podman-searxng.service \
    podman-wallabag-wallabag.service

  podman pull \
    docker.io/searxng/searxng:latest \
    ghcr.io/open-webui/open-webui:main \
    docker.io/wallabag/wallabag:latest

  sudo systemctl start \
    podman-wallabag-wallabag.service \
    podman-searxng.service \
    podman-openwebui.service \
