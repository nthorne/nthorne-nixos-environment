{
  pkgs,
  flake-inputs,
  ...
} @ args: let
  secretsFolders = builtins.toString flake-inputs.nix-secrets;
in {
  imports = [
    (import ../workstation.nix args)
    flake-inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    bashmount
    deluge
    sshfs-fuse
  ];

  sops = {
    age.keyFile = "/home/nthorne/.config/sops/age/keys.txt";
    defaultSopsFile = "${secretsFolders}/secrets.yaml";

    secrets = {
      "all/atuin/key".path = "/home/nthorne/.local/share/atuin/key";
      "all/atuin/session".path = "/home/nthorne/.local/share/atuin/session";
    };
  };

  # Also add these cloud models for private use
  programs.opencode.settings.provider.ollama.models = {
    "glm-5:cloud" = {
      name = "glm-5:cloud";
    };
    "qwen3.5:397b-cloud" = {
      name = "qwen3.5:397b-cloud";
    };
    "qwen3-coder-next:cloud" = {
      name = "qwen3-coder-next:cloud";
    };
    "gemini-3-flash-preview:cloud" = {
      name = "gemini-3-flash-preview:cloud";
    };
  };
}
