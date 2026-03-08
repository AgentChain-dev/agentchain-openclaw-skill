#!/usr/bin/env bash
set -euo pipefail

# Send CRD between accounts using agent_send (no passwords, keys stay in node)
# Usage: send.sh FROM TO AMOUNT_CRD

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

FROM="${1:?Usage: send.sh FROM TO AMOUNT_CRD}"
TO="${2:?Usage: send.sh FROM TO AMOUNT_CRD}"
AMOUNT="${3:?Usage: send.sh FROM TO AMOUNT_CRD}"

validate_address "$FROM"
validate_address "$TO"

# Convert CRD to hex wei
WEI=$(awk "BEGIN { printf \"%.0f\", $AMOUNT * 1000000000000000000 }")
HEX_WEI=$(printf "0x%x" "$WEI")

RESULT=$(rpc_call "{\"jsonrpc\":\"2.0\",\"method\":\"agent_send\",\"params\":[\"$FROM\",\"$TO\",\"$HEX_WEI\"],\"id\":1}")

if echo "$RESULT" | grep -q '"error"'; then
  echo "Transaction failed: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
  exit 1
fi

TX_HASH=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
echo "Transaction sent: $TX_HASH"
echo "Amount: $AMOUNT CRD"
echo "From: $FROM"
echo "To: $TO"
