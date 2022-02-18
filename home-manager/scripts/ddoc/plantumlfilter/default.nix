{ stable, ... }:
let
  remote = stable.fetchFromGitHub {
    owner = "jgm";
    repo = "pandocfilters";
    rev = "9638d1d956e85e0729b714c8713d553466982034";
    sha256 = "1x2z2rr33kfhdvwvq05glfvbvvh1d1sa2mw8j8ys5laczc1j5295";
  };

  pandocfilters = stable.python27Packages.buildPythonPackage rec {
    name = "pandocfilters";

    src = remote;

    buildInputs = [ ];
    propagatedBuildInputs = [ ];
  };
  pythonWrapper = (stable.python27.withPackages (ps: [pandocfilters]));
in
stdenv.mkDerivation {
  name = "plantumlfilter";

  src = remote;

  buildInputs = [ pandocfilters stable.plantuml ];

  buildCommand = ''
  mkdir -p $out/bin
  echo "#!${pythonWrapper}/bin/python" > $out/bin/plantuml.py
  sed 's|"java", "-jar", "plantuml.jar"|"${plantuml}/bin/plantuml"|' $src/examples/plantuml.py | sed 's|, latex="eps"||' >> $out/bin/plantuml.py
  chmod +x $out/bin/plantuml.py
  '';
}
