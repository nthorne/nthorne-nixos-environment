#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


handle_permissions() {
  usermod -u ${USER_ID} builder
  groupmod -g ${GROUP_ID} builder
  chown ${USER_ID}:${GROUP_ID} /home/builder
}


show_args() {
  echo "######################"
  echo "User id $USER_ID"
  echo "Group id $GROUP_ID"
  echo "Running lunch $lunch_targets"
  echo "Running make $make_targets"
  echo "######################"
}


build() {
  # Run lunch and make as none privilidge user
  su -c "source build/envsetup.sh && \
         lunch $lunch_targets && \
         make $make_targets" \
         builder
}


while getopts u:g:l:m: params ; do
  case $params in
    u)
        USER_ID=$OPTARG;;
    g)
        GROUP_ID=$OPTARG;;
    l)
        lunch_targets=$OPTARG;;
    m)
        make_targets=$OPTARG;;
  esac
done


main() {
  show_args
  handle_permissions
  build
}
main
