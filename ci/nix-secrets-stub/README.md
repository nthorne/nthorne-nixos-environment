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

so CI overrides the input with this stub, which has to be a valid flake directory
containing a `secrets.yaml`:

```sh
nix eval --override-input nix-secrets path:./ci/nix-secrets-stub .#nixosConfigurations.hex.config.system.build.toplevel.drvPath
```

An empty `secrets.yaml` is enough to *evaluate* the flake, but not to *build* it:
sops-nix generates its manifest during the build and rejects a key the
configuration references but the file does not contain —

```
manifest is not valid: secret all/atuin/key in .../secrets.yaml is not valid: the key 'all' cannot be found
```

so `secrets.yaml` here mirrors the key tree of the real file with placeholder
values. They are never decrypted before activation; the `sops.age` block is a real
age file encrypted to a throwaway recipient whose identity was discarded. Add a
key here when the configuration starts referencing a new one, or every CI build
of the affected host fails on `manifest.json`.

The `--override-input` is not written back to `flake.lock`. What CI therefore does *not*
cover is decryption at activation time, which it could not test anyway. A deploy key was
rejected on purpose: a key usable by every workflow run would expose the whole secrets
repo to any third-party action.

Never put real secrets in this directory.
