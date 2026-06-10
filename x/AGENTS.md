# Desktop Session Configuration

## Purpose

X11 and Wayland desktop session configuration: Niri, Hyprland, i3, XMonad, Waybar, Xresources, launcher helpers, startup scripts, and Vicinae helper scripts.

## Ownership

- Owns everything under `x/`.
- `niri.kdl` is the primary Niri compositor configuration.
- `hyprland/`, `i3/`, and XMonad files own alternate window manager configurations.
- `waybar/` owns bar layout, modules, style, and helper scripts.
- Top-level shell scripts are shared desktop helpers and startup entry points.

## Local Contracts

- Keep compositor-specific settings in their existing files or subdirectories; only promote shared logic to top-level scripts when reused.
- Preserve command names and paths referenced by keybindings, startup hooks, and Waybar modules.
- Do not embed credentials, access tokens, or host-private values in desktop scripts or configs.
- Treat generated runtime state and local per-machine overrides as out of scope for tracked files unless explicitly documented.

## Work Guidance

- Prefer small, direct config edits over introducing shared abstractions across compositors.
- For shell helpers, keep scripts POSIX-compatible unless the shebang explicitly requires another shell.
- For JSONC and KDL files, preserve comments and existing formatting style around the edited block.

## Verification

- For shell script changes, run `bash -n` on each affected script.
- For compositor, Waybar, or launcher config changes, run the nearest tool-specific validator if available in the environment; none is currently recorded here.

## Child DOX Index

No child DOX files.
