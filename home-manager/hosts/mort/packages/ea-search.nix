{
  rustPlatform,
  pkg-config,
  sqlite,
}:
rustPlatform.buildRustPackage {
  pname = "ea-search";
  version = "0.1.0";
  src = ./ea-search;
  cargoLock.lockFile = ./ea-search/Cargo.lock;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sqlite ];
}
