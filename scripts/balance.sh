#!/usr/bin/env bash
set -euo pipefail

# Get CRD balance for an address (human-readable)
# Usage: balance.sh ADDRESS

RPC="${AGENTCHAIN_RPC:-http://165.232.86.29:8545}"
ADDRESS="${1:?Usage: balance.sh ADDRESS}"

# Validate address format
if [[ ! "$ADDRESS" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
  echo "Error: Invalid address format. Must be 0x followed by 40 hex characters." >&2
  exit 1
fi

RESULT=$(curl -s -X POST "$RPC" \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBalance\",\"params\":[\"$ADDRESS\",\"latest\"],\"id\":1}")

# Check for RPC error
if echo "$RESULT" | grep -q '"error"'; then
  echo "RPC Error: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
  exit 1
fi

HEX=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)

if [ -z "$HEX" ] || [ "$HEX" = "0x0" ]; then
  echo "0.0000 CRD"
  exit 0
fi

# Convert hex wei to decimal CRD using awk (portable, no bc/python needed)
DECIMAL=$(printf "%d" "$HEX" 2>/dev/null || echo "0")
CRD=$(awk "BEGIN { printf \"%.4f\", $DECIMAL / 1000000000000000000 }")

echo "$CRD CRD"
