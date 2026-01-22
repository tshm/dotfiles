#!/usr/bin/env zsh
# OpenCode Config Merger
# Combines modular JSON config files into a single opencode.json

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
OUTPUT_FILE="$SCRIPT_DIR/opencode.jsonc"
BACKUP_FILE="$SCRIPT_DIR/opencode.jsonc.backup"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

strip_jsonc() {
    python - "$1" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as handle:
    data = handle.read()

out = []
i = 0
in_string = False
escape = False
length = len(data)

while i < length:
    ch = data[i]
    nxt = data[i + 1] if i + 1 < length else ""

    if in_string:
        out.append(ch)
        if escape:
            escape = False
        elif ch == "\\":
            escape = True
        elif ch == '"':
            in_string = False
        i += 1
        continue

    if ch == '"':
        in_string = True
        out.append(ch)
        i += 1
        continue

    if ch == "/" and nxt == "/":
        i += 2
        while i < length and data[i] not in "\r\n":
            i += 1
        continue

    if ch == "/" and nxt == "*":
        i += 2
        while i + 1 < length and not (data[i] == "*" and data[i + 1] == "/"):
            i += 1
        i += 2
        continue

    out.append(ch)
    i += 1

data = "".join(out)
out = []
i = 0
in_string = False
escape = False
length = len(data)

while i < length:
    ch = data[i]
    if in_string:
        out.append(ch)
        if escape:
            escape = False
        elif ch == "\\":
            escape = True
        elif ch == '"':
            in_string = False
        i += 1
        continue

    if ch == '"':
        in_string = True
        out.append(ch)
        i += 1
        continue

    if ch == ",":
        j = i + 1
        while j < length and data[j].isspace():
            j += 1
        if j < length and data[j] in "]}":
            i += 1
            continue

    out.append(ch)
    i += 1

sys.stdout.write("".join(out))
PY
}

# Check for jq
if which jq &> /dev/null; then
else
    log_error "jq is not installed. Please install it first:"
    log_error "  Ubuntu/Debian: sudo apt-get install jq"
    log_error "  macOS: brew install jq"
    log_error "  Arch: sudo pacman -S jq"
    exit 1
fi

# Check if config directory exists
if [ ! -d "$CONFIG_DIR" ]; then
    log_error "Config directory not found: $CONFIG_DIR"
    exit 1
fi

# Backup existing opencode.json if it exists
if [ -f "$OUTPUT_FILE" ]; then
    log_info "Backing up existing $OUTPUT_FILE to $BACKUP_FILE"
    cp "$OUTPUT_FILE" "$BACKUP_FILE"
fi

log_info "Merging config files from: $CONFIG_DIR"

# Start with base config
BASE_CONFIG='{
  "$schema": "https://opencode.ai/config.json"
}'

# Merge tools if exists
if [ -f "$CONFIG_DIR/tools.jsonc" ]; then
    log_info "  + tools.jsonc"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile tools <(strip_jsonc "$CONFIG_DIR/tools.jsonc") '. + {tools: $tools[0]}')
fi

# Merge mcp if exists
if [ -f "$CONFIG_DIR/mcp.jsonc" ]; then
    log_info "  + mcp.jsonc"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile mcp <(strip_jsonc "$CONFIG_DIR/mcp.jsonc") '. + {mcp: $mcp[0]}')
fi

# Merge plugins if exists
if [ -f "$CONFIG_DIR/plugins.jsonc" ]; then
    log_info "  + plugins.jsonc"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile plugin <(strip_jsonc "$CONFIG_DIR/plugins.jsonc") '. + {plugin: $plugin[0]}')
fi

# Merge providers if exists
if [ -f "$CONFIG_DIR/providers.jsonc" ]; then
    log_info "  + providers.jsonc"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile provider <(strip_jsonc "$CONFIG_DIR/providers.jsonc") '. + {provider: $provider[0]}')
fi

# Merge any additional config files (keybinds, server, etc.)
for config_file in "$CONFIG_DIR"/*.jsonc; do
    filename=$(basename "$config_file" .jsonc)

    # Skip files we've already processed
    if [[ "$filename" == "tools" || "$filename" == "mcp" || "$filename" == "plugins" || "$filename" == "providers" ]]; then
        continue
    fi

    log_info "  + $filename.jsonc"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile data <(strip_jsonc "$config_file") '. + {("'"$filename"'"): $data[0]}')
done

# Write final config
echo "$BASE_CONFIG" | jq '.' > "$OUTPUT_FILE"

log_info "Successfully generated: $OUTPUT_FILE"
log_info "Done!"
