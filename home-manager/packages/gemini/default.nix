{pkgs, ...}: {
  home.packages = with pkgs; [
    (buildNpmPackage (finalAttrs: {
      buildInputs = [nodejs];

      pname = "gemini-cli";
      version = "2025-06-27";
      src = fetchFromGitHub {
        owner = "google-gemini";
        repo = "gemini-cli";
        rev = "6742a1b7f97033d1301f4159b67ef0d9587f65f2";
        sha256 = "sha256-ikrzodJQyO861Uyz/Ud+b0N2aIwLkwCG/eHLXknX5Jc=";
      };

      npmDepsHash = "sha256-qimhi2S8fnUbIq2MPU1tlvj5k9ZChY7kzxLrYqy9FXI=";
      preFixup = ''
        find "$out" -xtype l -exec rm -v {} +
      '';
    }))
  ];
}

