#!/usr/bin/env bash
set -euo pipefail

# Send CRD between accounts using agent_send (no passwords, keys stay in node)
# Usage: send.sh FROM TO AMOUNT_CRD

RPC="${AGENTCHAIN_RPC:-http://165.232.86.29:8545}"
FROM="${1:?Usage: send.sh FROM TO AMOUNT_CRD}"
TO="${2:?Usage: send.sh FROM TO AMOUNT_CRD}"
AMOUNT="${3:?Usage: send.sh FROM TO AMOUNT_CRD}"

# Validate addresses
for ADDR in "$FROM" "$TO"; do
  if [[ ! "$ADDR" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
    echo "Error: Invalid address format: $ADDR" >&2
    exit 1
  fi
done

# Convert CRD to hex wei
WEI=$(awk "BEGIN { printf \"%.0f\", $AMOUNT * 1000000000000000000 }")
HEX_WEI=$(printf "0x%x" "$WEI")

# Send via agent_send — the node signs internally, no keys are exposed
RESULT=$(curl -s -X POST "$RPC" \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"agent_send\",\"params\":[\"$FROM\",\"$TO\",\"$HEX_WEI\"],\"id\":1}")

if echo "$RESULT" | grep -q '"error"'; then
  echo "Transaction failed: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
  exit 1
fi

TX_HASH=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
echo "Transaction sent: $TX_HASH"
echo "Amount: $AMOUNT CRD"
echo "From: $FROM"
echo "To: $TO"
