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

# TODO: Change to Amir's workspace folder.
REPO_BASE_PATH="/home/nthorne/work/"
# TODO: Change the container name to whatever Amir tags his image with.
CONTAINER_NAME="android-env-ci"
# TODO: Change to wherever Amir has his .ccache folder
CCACHE_CACHE_PATH="/home/nthorne/.ccache"


PROJECT=
REPO_PATH=


function usage()
{
  cat <<Usage_Heredoc
Usage: $(basename $0) <PROJECT> [OPTIONS]

Enter an AOSP shell in PROJECT.

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
        if [[ -z "$PROJECT" ]]
        then
          PROJECT=$1
        else
          error "Unknown option: $1. Try $(basename $0) -h for options."
        fi
        ;;
    esac

    shift
  done

  # Validate input
  test -n "${PROJECT}" || error "Missing PROJECT. Try $(basename $0) -h for options."

  REPO_PATH="/${REPO_BASE_PATH}/${PROJECT}"
  test -d "$REPO_PATH" || error "$REPO_PATH: No such folder."
}

parse_options "$@"

docker run \
  --rm \
  -v $REPO_PATH:/home/aosp_builder/aosp_src \
  -v ${CCACHE_CACHE_PATH}:/opt/ccache \
  --privileged -v /dev/bus/usb:/dev/bus/usb \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e CCACHE_DIR=/opt/ccache \
  -e USE_CCACHE=1 \
  -e CCACHE_EXEC=/usr/local/bin/ccache \
  -e CCACHE_FILECLONE=1 \
  --hostname=bob \
  -ti \
  ${CONTAINER_NAME} \
  /bin/bash
