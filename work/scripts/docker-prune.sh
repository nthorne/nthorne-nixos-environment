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



function usage()
{
  cat <<Usage_Heredoc
Usage: $(basename $0) [OPTIONS]

Prune terminated docker sessions, and dangling images.

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

function docker_prune()
{
  docker ps -a -f status=exited -q | xargs docker rm
  docker images -f dangling=true -q | xargs docker rmi
}


parse_options "$@"
docker_prune
