{pkgs, name, xhost, extras ? "" }:
pkgs.writeShellScriptBin "run-${name}" ''
  USER_ID="$(id -u "$USER")"
  ${xhost}/bin/xhost +si:localuser:$USER

  # NOTE: By passing $@ as final argument here, we can fire up
  #       the container, and execute any command inside it.

  docker run \
    --rm \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    --privileged -v /dev/bus/usb:/dev/bus/usb \
    --device /dev/kvm \
    -u "$USER_ID" \
    -e HOME=$HOME \
    -e USER=$USER \
    -v $HOME/:$HOME \
    -v /mnt/as:/mnt/as \
    -v /mnt/pkg:/mnt/pkg \
    -v /mnt/pkg:/pkg \
    -w "$PWD" \
    ${extras} \
    -it "${name}" \
    $@
''
