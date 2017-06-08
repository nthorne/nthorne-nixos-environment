with import <nixpkgs> { };

pkgs.python27Packages.buildPythonPackage rec {
    name = "cppclean-0.12";

    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/5d/b6/add9db6792f6a2f1fe09341a668deda702e1d8c6b893d867c387fe28ec49/${name}.tar.gz";
      sha256 = "05p0qsmrn3zhp33rhdys0ddn8hql6z25sdvbnccqwps8jai5wq2r";
    };
}
