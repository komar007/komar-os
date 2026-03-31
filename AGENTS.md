# Repo Notes

- When working in this flake, add new files to the git index if Nix evaluates or references them.
  Untracked files are not included in the flake source snapshot and can fail evaluation/builds.
- There is no need to `git add` new files that are not evaluated by Nix.
- Before `nix flake check --all-systems`, run `nix fmt`. This avoids irrelevant formatter failures
  and makes `nix flake check --all-systems` verify the final formatted tree rather than a pre-format
  intermediate state.
- Verify changes with `nix flake check --all-systems`.
- If `nix flake check --all-systems` fails, first revert the latest changes and rerun it to check
  whether the failure reproduces without them.
  - If the failure still happens after reverting the latest changes, refuse to continue and ask how
    to proceed.
  - If the failure disappears after reverting the latest changes, proceed assuming the latest edits
    caused it.
- Scripts built with `writeShellApplication` must be safe under `set -u` and pass ShellCheck unless
  a specific warning is intentionally suppressed locally.
