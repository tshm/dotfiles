#!/bin/sh
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$tmp/bin"
export XDG_STATE_HOME="$tmp/state" XDG_CACHE_HOME="$tmp/cache"

# Replace only the external evaluation and deployed-path boundaries.
cat > "$tmp/bin/nix" <<'EOF'
#!/bin/sh
case "$*" in
    *nixosConfigurations*)
        [ "$SCENARIO" != eval-error ] || exit 1
        printf /nix/store/test-system ;;
    *homeConfigurations*) printf /nix/store/test-home ;;
    *) exit 1 ;;
esac
EOF
cat > "$tmp/bin/readlink" <<'EOF'
#!/bin/sh
case "$2" in
    /run/current-system|/run/booted-system) printf /nix/store/test-system ;;
    /nix/var/nix/profiles/system)
        if [ "$SCENARIO" = drift ]; then printf /nix/store/old-system;
        else printf /nix/store/test-system; fi ;;
    */home-manager/gcroots/current-home)
        [ "$SCENARIO" != missing ] || exit 1
        if [ "$SCENARIO" = drift ]; then printf /nix/store/old-home;
        else printf /nix/store/test-home; fi ;;
    */home-manager) printf /nix/store/test-home ;;
    *) exit 1 ;;
esac
EOF
chmod +x "$tmp/bin/nix" "$tmp/bin/readlink"
export PATH="$tmp/bin:$PATH"

run() {
    SCENARIO=$1
    export SCENARIO
    rc=0
    output=$(make --no-print-directory -s -C "$repo" check-config \
        ISNIXOS="$2" PRIVATE_FLAKE= NIXOS_FLAKE=. NIXOS_FLAKE_ARGS= 2>&1) || rc=$?
}
contains() {
    printf '%s\n' "$output" | grep -F -- "$1" >/dev/null || {
        printf 'Missing report: %s\n%s\n' "$1" "$output" >&2
        exit 1
    }
}

run match 1
[ "$rc" -eq 0 ]
contains '[OK] NixOS: next boot'
contains '[OK] Home Manager: activated'

run drift 1
[ "$rc" -ne 0 ]
contains '[DIFF] NixOS: next boot'
contains 'actual:   /nix/store/old-system'
contains '[DIFF] Home Manager: activated'
contains 'actual:   /nix/store/old-home'

run missing 1
[ "$rc" -ne 0 ]
contains '[DIFF] Home Manager: activated'
contains 'actual:   <missing>'

run eval-error 1
[ "$rc" -ne 0 ]
contains '[ERROR] NixOS evaluation failed'
contains '[OK] Home Manager: activated'

run match ''
[ "$rc" -eq 0 ]
contains '[SKIP] NixOS: not a NixOS host'
contains '[OK] Home Manager: activated'

printf 'check-config: matching, drift, missing, evaluation failure, non-NixOS checks passed\n'
