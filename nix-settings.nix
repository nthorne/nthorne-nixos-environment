_:
{
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
  };
}
