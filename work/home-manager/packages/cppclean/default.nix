{pkgs, ...}:
pkgs.python27Packages.buildPythonPackage rec {
  name = "cppclean";
  version = "0.13";

  src = pkgs.fetchFromGitHub {
    rev = "v${version}";
    repo = name;
    owner = "myint";

    sha256 = "081bw7kkl7mh3vwyrmdfrk3fgq8k5laacx7hz8fjpchrvdrkqph0";
    };
}
