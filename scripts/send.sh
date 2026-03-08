#!/usr/bin/env bash
set -euo pipefail

# Send CRD between accounts
# Usage: send.sh FROM TO AMOUNT_CRD PASSWORD

RPC="${AGENTCHAIN_RPC:-http://165.232.86.29:8545}"
FROM="${1:?Usage: send.sh FROM TO AMOUNT_CRD PASSWORD}"
TO="${2:?Usage: send.sh FROM TO AMOUNT_CRD PASSWORD}"
AMOUNT="${3:?Usage: send.sh FROM TO AMOUNT_CRD PASSWORD}"
PASSWORD="${4:?Usage: send.sh FROM TO AMOUNT_CRD PASSWORD}"

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

# Unlock account (300 second duration)
UNLOCK=$(curl -s -X POST "$RPC" \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"personal_unlockAccount\",\"params\":[\"$FROM\",\"$PASSWORD\",300],\"id\":1}")

if echo "$UNLOCK" | grep -q '"error"'; then
  echo "Failed to unlock account: $(echo "$UNLOCK" | grep -o '"message":"[^"]*"')" >&2
  exit 1
fi

# Send transaction
RESULT=$(curl -s -X POST "$RPC" \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_sendTransaction\",\"params\":[{\"from\":\"$FROM\",\"to\":\"$TO\",\"value\":\"$HEX_WEI\"}],\"id\":1}")

if echo "$RESULT" | grep -q '"error"'; then
  echo "Transaction failed: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
  exit 1
fi

TX_HASH=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
echo "Transaction sent: $TX_HASH"
echo "Amount: $AMOUNT CRD"
echo "From: $FROM"
echo "To: $TO"
