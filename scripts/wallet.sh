#!/usr/bin/env bash
set -euo pipefail

# Wallet management for AgentChain using agent_* API
# Keys never leave the node — no passwords needed
# Usage: wallet.sh create
#        wallet.sh list

RPC="${AGENTCHAIN_RPC:-http://165.232.86.29:8545}"
COMMAND="${1:?Usage: wallet.sh <create|list>}"

case "$COMMAND" in
  create)
    RESULT=$(curl -s -X POST "$RPC" \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","method":"agent_createWallet","params":[],"id":1}')

    if echo "$RESULT" | grep -q '"error"'; then
      echo "Failed to create wallet: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
      exit 1
    fi

    ADDRESS=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    echo "Wallet created: $ADDRESS"
    echo "Keys are stored securely inside the node."
    ;;

  list)
    RESULT=$(curl -s -X POST "$RPC" \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","method":"agent_listWallets","params":[],"id":1}')

    if echo "$RESULT" | grep -q '"error"'; then
      echo "Failed to list wallets: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
      exit 1
    fi

    echo "=== Wallets ==="
    echo "$RESULT" | grep -o '0x[0-9a-fA-F]\{40\}' | while read -r addr; do
      echo "  $addr"
    done
    ;;

  *)
    echo "Unknown command: $COMMAND" >&2
    echo "Usage: wallet.sh <create|list>" >&2
    exit 1
    ;;
esac
