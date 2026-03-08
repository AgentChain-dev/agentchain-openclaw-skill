#!/usr/bin/env bash
set -euo pipefail

# Wallet management for AgentChain
# Usage: wallet.sh create PASSWORD
#        wallet.sh list

RPC="${AGENTCHAIN_RPC:-http://165.232.86.29:8545}"
COMMAND="${1:?Usage: wallet.sh <create|list> [PASSWORD]}"

case "$COMMAND" in
  create)
    PASSWORD="${2:?Usage: wallet.sh create PASSWORD}"
    RESULT=$(curl -s -X POST "$RPC" \
      -H "Content-Type: application/json" \
      -d "{\"jsonrpc\":\"2.0\",\"method\":\"personal_newAccount\",\"params\":[\"$PASSWORD\"],\"id\":1}")

    if echo "$RESULT" | grep -q '"error"'; then
      echo "Failed to create wallet: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
      exit 1
    fi

    ADDRESS=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    echo "Wallet created: $ADDRESS"
    echo "IMPORTANT: Store your password securely. It cannot be recovered."
    ;;

  list)
    RESULT=$(curl -s -X POST "$RPC" \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}')

    if echo "$RESULT" | grep -q '"error"'; then
      echo "Failed to list accounts: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
      exit 1
    fi

    echo "=== Accounts ==="
    echo "$RESULT" | grep -o '0x[0-9a-fA-F]\{40\}' | while read -r addr; do
      echo "  $addr"
    done
    ;;

  *)
    echo "Unknown command: $COMMAND" >&2
    echo "Usage: wallet.sh <create|list> [PASSWORD]" >&2
    exit 1
    ;;
esac
