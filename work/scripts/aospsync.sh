#!/usr/bin/env bash

# vim: filetype=sh

# TODO: Update the readme.

ACTION=usage
PROJECT=
REMOTE=
LUNCH_TARGET=

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
Usage: $(basename $0) <COMMAND> [OPTIONS] [CMDLINE]

$(basename $0) is a tool for convenient local editing, combined with remote
building.

Wher valid COMMANDs are:
  sync   uses rsync to copy the sources, excluding version control
         and build folders, from local to remote.
  build  build the source tree on the remote.
  flash  copy the build result from the remote to the local, and flash
         onto the unit.
  shell  fires up a shell in the project folder on the remote.
  clean  clean any build results.
  init   initialize a new project; copies the entire project to the remote;
         this is needed in order to get VCS folder etc in place.
  remove remove the project from the remote.

Where valid OPTIONS are:
  -h, --help     display usage
  -p, --project  details the local project root folder.
  -r, --remote   details the remote build server. Passwordless login
                 must be setup on this host.
  -t, --target   details lunch target.

Usage_Heredoc
}

function error()
{
  echo "Error: $@" >&2
  exit 1
}

function usage_error()
{
  error "$@ Try $(basename $0) -h for options."
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
      sync)
        ACTION=sync_project
        execute_action
        ;;
      shell)
        ACTION=remote_shell
        execute_action
        ;;
      build)
        ACTION=build_project
        execute_action
        ;;
      flash)
        ACTION=flash_project
        execute_action
        ;;
      clean)
        ACTION=clean_project
        execute_action
        ;;
      init)
        ACTION=init_project
        execute_action
        ;;
      remove)
        ACTION=remove_project
        execute_action
        ;;
      -p|--project)
        shift
        if [[ -n "$1" ]]
        then
          PROJECT="$1"
        fi
        ;;
      -r|--remote )
        shift
        if [[ -n "$1" ]]
        then
          REMOTE="$1"
        fi
        ;;
      -t|--target)
        shift
        if [[ -n "$1" ]]
        then
          LUNCH_TARGET="$1"
        fi
        ;;
      *)
        usage_error "Unknown option: $1."
        ;;
    esac

    shift
  done
}

function validate_options()
{
  test -n "$PROJECT" || usage_error "Project path not set."
  test -n "$REMOTE" || usage_error "Remote server not set."
}


# TODO: This takes hella time the first time. Also, I think that is not
#       such a good idea to replace symlinks with copies; will waste a
#       lot of disk. Perhaps add a setup action, and have sync require
#       that the target folder exists.
function sync_project()
{
  echo "Syncing $PROJECT to $TARGET_FOLDER"

  ssh $USER@$REMOTE "mkdir -p $TARGET_FOLDER" \
    || error "Unable to create remote folder. Is passwordless login configured?"

  # Ignore any version control folders (all VCS is to be done locally), and
  # build result folder (so that we don't remove the build on the remote on
  # every sync). Also, don't bother messing with the symlinks.

  rsync -Karv --delete --exclude=*/.git/ --exclude=*/.repo/ --exclude=*/out/ $PROJECT $USER@$REMOTE:$TARGET_FOLDER
}

# TODO: How the f* do I combine --login and --init-file? Can't get it
#       to work, which otherwise would allow for logged in to a pre-
#       lunched shell.
function remote_shell()
{
  ssh -t $USER@$REMOTE "bash --login -c 'cd sync/$PROJECT; bash --login'"
}

function build_project()
{
  test -n "$LUNCH_TARGET" || usage_error "Lunch target not set."
  ssh $USER@$REMOTE "bash --login -c 'cd sync/$PROJECT && . ./build/envsetup.sh && lunch $LUNCH_TARGET && nice make droid flashfiles'"
}

function clean_project()
{
  test -n "$LUNCH_TARGET" || usage_error "Lunch target not set."
  ssh $USER@$REMOTE "bash --login -c 'cd sync/$PROJECT && . ./build/envsetup.sh && lunch $LUNCH_TARGET && nice make clean'"
}

function init_project()
{
  echo "Initializing $PROJECT in $TARGET_FOLDER"

  ssh $USER@$REMOTE "mkdir -p $TARGET_FOLDER" \
    || error "Unable to create remote folder. Is passwordless login configured?"

  # Sync everything, excluding build results to the target, since
  # VCS files are needed for the build :/
  rsync -Karv --delete --exclude=*/out/ $PROJECT $USER@$REMOTE:$TARGET_FOLDER

}

function remove_project()
{
  local readonly p=$(basename $PROJECT)

  ssh $USER@$REMOTE "bash --login -c 'cd sync/$PROJECT && cd .. && rm -rf $p"
}

function flash_project()
{
  local readonly flashdir=$HOME/tmp/flashing
  mkdir -p $HOME/tmp/flashing || error "unable to create flash dir $flashdir"

  pushd $flashdir || error "$flashdir: no such folder"
  rm ./*
  scp $USER@$REMOTE:sync/$PROJECT/out/target/product/\*/\*-flashfiles-\*.zip .
  unzip ./*.zip
  android-env "bash ./fastboot.sh --abl --disable-verity"
  popd
}

function execute_action()
{
  validate_options

  TARGET_FOLDER="sync/$(dirname $PROJECT)"

  $ACTION
}

parse_options "$@"
