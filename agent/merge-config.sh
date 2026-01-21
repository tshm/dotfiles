#!/usr/bin/env zsh
# OpenCode Config Merger
# Combines modular JSON config files into a single opencode.json

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
OUTPUT_FILE="$SCRIPT_DIR/opencode.json"
BACKUP_FILE="$SCRIPT_DIR/opencode.json.backup"

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
    log_info "Backing up existing opencode.json to opencode.json.backup"
    cp "$OUTPUT_FILE" "$BACKUP_FILE"
fi

log_info "Merging config files from: $CONFIG_DIR"

# Start with base config
BASE_CONFIG='{
  "$schema": "https://opencode.ai/config.json"
}'

# Merge tools if exists
if [ -f "$CONFIG_DIR/tools.json" ]; then
    log_info "  + tools.json"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile tools "$CONFIG_DIR/tools.json" '. + {tools: $tools[0]}')
fi

# Merge mcp if exists
if [ -f "$CONFIG_DIR/mcp.json" ]; then
    log_info "  + mcp.json"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile mcp "$CONFIG_DIR/mcp.json" '. + {mcp: $mcp[0]}')
fi

# Merge plugins if exists
if [ -f "$CONFIG_DIR/plugins.json" ]; then
    log_info "  + plugins.json"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile plugin "$CONFIG_DIR/plugins.json" '. + {plugin: $plugin[0]}')
fi

# Merge providers if exists
if [ -f "$CONFIG_DIR/providers.json" ]; then
    log_info "  + providers.json"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile provider "$CONFIG_DIR/providers.json" '. + {provider: $provider[0]}')
fi

# Merge any additional config files (keybinds, server, etc.)
for config_file in "$CONFIG_DIR"/*.json; do
    filename=$(basename "$config_file" .json)

    # Skip files we've already processed
    if [[ "$filename" == "tools" || "$filename" == "mcp" || "$filename" == "plugins" || "$filename" == "providers" ]]; then
        continue
    fi

    log_info "  + $filename.json"
    BASE_CONFIG=$(echo "$BASE_CONFIG" | jq --slurpfile data "$config_file" '. + {("'"$filename"'"): $data[0]}')
done

# Write final config
echo "$BASE_CONFIG" | jq '.' > "$OUTPUT_FILE"

log_info "Successfully generated: $OUTPUT_FILE"
log_info "Done!"
