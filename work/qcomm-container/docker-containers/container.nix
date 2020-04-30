{stdenv, name, dockersource, xhost}:

let
build = ''
#!/usr/bin/env bash

DIR="$( cd "$( dirname "''${BASH_SOURCE[0]}" )" && pwd )"

  cat << 'EOT' | docker build -t "${name}" -
${dockersource}
EOT
'';

run = ''
#!/usr/bin/env bash

USER_ID="$(id -u "$USER")"
${xhost}/bin/xhost +si:localuser:$USER

# NOTE: By passing $@ as final argument here, we can fire up
#       the container, and execute any command inside it.

docker run \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  --privileged -v /dev/bus/usb:/dev/bus/usb \
  --device /dev/kvm \
  -u "$USER_ID" \
  -e HOME=$HOME \
  -e USER=$USER \
  -v $HOME/:$HOME \
  -v /mnt/pkg:/pkg \
  -v /mnt/external:/mnt/external \
  -e HEXAGON_ROOT=/pkg/qct/software/hexagon/releases/tools \
  -w "$PWD" \
  -it "${name}" \
  $@
'';

in
stdenv.mkDerivation {
  name = name;

  buildInputs = [ xhost ];

  buildCommand = ''
    mkdir -p $out/bin
    cat << 'EOF' > $out/bin/build-${name}
${build}
EOF
    chmod +x $out/bin/build-${name}

    cat << 'EOF' > $out/bin/${name}
${run}
EOF
    chmod +x $out/bin/${name}
  '';
}
