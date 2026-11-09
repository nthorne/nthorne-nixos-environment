# nix-secrets CI stub

`flake.nix` takes `nix-secrets` as a private SSH input:

```nix
nix-secrets.url = "git+ssh://git@github.com/nthorne/nix-secrets.git?allRefs=true&ref=main";
```

`flake.lock` pins a revision, so *every* evaluation of this flake — including a bare
`nix eval` — needs SSH read access to that repo. GitHub-hosted runners have no such key.

Nothing reads the secrets tree at evaluation time; `nix-secrets` is only used as a path:

- `flake.nix` — `sops.defaultSopsFile = "${inputs.nix-secrets}/secrets.yaml"`
- `home-manager/hosts/hex/default.nix`, `home-manager/hosts/workstation.nix` —
  `secretsFolders = builtins.toString flake-inputs.nix-secrets`

so CI overrides the input with this stub, which only has to be a valid flake directory
containing a `secrets.yaml`:

```sh
nix eval --override-input nix-secrets path:./ci/nix-secrets-stub .#nixosConfigurations.hex.config.system.build.toplevel.drvPath
```

The `--override-input` is not written back to `flake.lock`. What CI therefore does *not*
cover is decryption at activation time, which it could not test anyway. A deploy key was
rejected on purpose: a key usable by every workflow run would expose the whole secrets
repo to any third-party action.

Never put real secrets in this directory.
