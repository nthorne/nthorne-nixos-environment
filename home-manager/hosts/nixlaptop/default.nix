{
  pkgs,
  ...
}@args:
{
  imports = [
    (import ../workstation.nix args)
  ];

  home.packages = with pkgs; [
    bashmount
    deluge
    obsidian
    sshfs-fuse
  ];

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
