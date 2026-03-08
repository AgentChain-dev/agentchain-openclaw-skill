#!/usr/bin/env bash
set -euo pipefail

# Get CRD balance for an address (human-readable)
# Usage: balance.sh ADDRESS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

ADDRESS="${1:?Usage: balance.sh ADDRESS}"
validate_address "$ADDRESS"

RESULT=$(rpc_call "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"$ADDRESS\",\"latest\"],\"id\":1}")

if echo "$RESULT" | grep -q '"error"'; then
  echo "RPC Error: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
  exit 1
fi

HEX=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

if [ -z "$HEX" ] || [ "$HEX" = "0x0" ]; then
  echo "0.0000 CRD"
  exit 0
fi

DECIMAL=$(printf "%d" "$HEX" 2>/dev/null || echo "0")
CRD=$(awk "BEGIN { printf \"%.4f\", $DECIMAL / 1000000000000000000 }")

echo "$CRD CRD"
