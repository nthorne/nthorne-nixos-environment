{
  pkgs,
  ...
}@args:
{
  imports = [
    (import ../workstation.nix args)

    ../../packages/copilot-cli
    ../../packages/pi-agent
  ];

  home.packages =
    with pkgs;
    [
      ctags
      entr
      gdb
      insomnia
      libxml2
      lnav
      nvtopPackages.full
      p7zip
      remmina
      tmuxinator
      wget
    ]
    ++ [
      (pkgs.callPackage ../../packages/open-ralph-wiggum { })
    ];

  sops.secrets = {
    "vimes/ssh_keys/rsa_pub".path = "/home/nthorne/.ssh/id_rsa.pub";
    "vimes/ssh_keys/rsa_secret".path = "/home/nthorne/.ssh/id_rsa";
  };

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = {
        "github.com" = {
          hostname = "github.com";
          identityFile = "/home/nthorne/.ssh/id_rsa";
        };
      };
    };

    zsh.shellAliases = {
      nlsh = ''nlsh() { curl -s localhost:11434/api/generate -d "{\"model\": \"westenfelder/NL2SH\", \"prompt\": \"$1\", \"stream\": false}" | jq -r '.response'}; nlsh'';
    };

    opencode.settings.provider.ollama.models = {
      "gemma4:latest" = {
        name = "gemma4:latest";
      };
      "qwen3-coder:latest" = {
        name = "qwen3-coder:latest";
      };
      "qwen3.5:latest" = {
        name = "qwen3.5:latest";
      };
    };

    firefox.profiles.default = {
      # Points Home Manager to your existing profile directory
      path = "xon5n7p1.default";
      isDefault = true;
    };

    pi-coding-agent = {
      settings = {
        defaultProvider = "openrouter";
        defaultModel = "deepseek/deepseek-v4-flash";
      };
      models = {
        "providers" = {
          "ollama" = {
            "baseUrl" = "http://localhost:11434/v1";
            "api" = "openai-completions";
            "apiKey" = "ollama";
            "models" = [
              {
                "id" = "qwen3-coder";
              }
            ];
          };
        };
      };
    };
  };
}
