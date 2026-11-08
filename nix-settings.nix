_:
{
  nix.settings = {
    # Use all available CPU cores for parallel compilation
    cores = 0;
    # Build as many packages in parallel as possible
    max-jobs = "auto";
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
  };
}
