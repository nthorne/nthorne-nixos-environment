I use uv2nix here in order to get robotcode into my configs in a convenient way.
This means that any verison updates need to go through `uv lock` + uv2nix, but
declaring the packages manually did not work properly as there are circular
dependencies between packages.
