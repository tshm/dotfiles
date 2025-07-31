running `make` will build nix derivation.
but it is now failing. please fix the issue.

- i added opencode-ai package via node2nix tool
- nix files within ./homes/modules/node2nix are all node2nix generated files.
  so do not change them.
- the output of node2nix is used from ./homes/modules/dev.nix.
- i also added gemini-cli in same way, and it seems to give no error and is working.
