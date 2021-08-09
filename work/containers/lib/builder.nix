{pkgs, name, dockersource}:
pkgs.writeShellScriptBin "build-${name}" ''
  DIR="$( cd "$( dirname "''${BASH_SOURCE[0]}" )" && pwd )"
  cat << 'EOT' | docker build -t "${name}" -
  ${dockersource}
  EOT
''
