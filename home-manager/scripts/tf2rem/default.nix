{pkgs, ...}: let
  tf2rem = pkgs.writeShellApplication {
    name = "tf2rem";
    runtimeInputs = with pkgs; [
      terraform
      jq
      remmina
    ];
    text = ''
      #!/usr/bin/env bash

      # Get remmina profile name from the first argument
      remmina_profile_name="$1"
      if [ -z "''${remmina_profile_name}" ]; then
        echo "Usage: $0 <remmina_profile_name>"
        exit 1
      fi

      # Show terraform output
      terraform_output=$(terraform output -json)

      # Ensure only single IP address is returned
      if [ "$(echo "''${terraform_output}" | jq -r '.public_ips.value | length')" -ne 1 ]; then
        echo "Error: Expected exactly one public IP address, but found multiple or none."
        exit 1
      fi

      password=$(echo "''${terraform_output}" | jq -r '.password.value')
      public_ips=$(echo "''${terraform_output}" | jq -r '.public_ips.value[]')

      # Glob match the Remmina profile
      profile_path=$(find ~/.local/share/remmina/ -iname \*_"''${remmina_profile_name}"_\*.remmina)

      # Make sure that only a single profile is matched
      if [ "$(echo "''${profile_path}" | wc -l)" -ne 1 ]; then
        echo "Error: Expected exactly one Remmina profile, but found multiple or none."
        exit 1
      fi

      # Update the Remmina profile with the public IPs and password
      echo "''${password}" | remmina --update-profile "''${profile_path}" --set-option server="''${public_ips}" --set-option password
    '';
  };
in {
  home.packages = with pkgs; [
    tf2rem
  ];
}
