#!/usr/bin/env bash
set -euo pipefail

# Wallet management for AgentChain using agent_* API
# Keys never leave the node — no passwords needed
# Usage: wallet.sh create
#        wallet.sh list

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

COMMAND="${1:?Usage: wallet.sh <create|list>}"

case "$COMMAND" in
  create)
    RESULT=$(rpc_call '{"jsonrpc":"2.0","method":"agent_createWallet","params":[],"id":1}')

    if echo "$RESULT" | grep -q '"error"'; then
      echo "Failed to create wallet: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
      exit 1
    fi

    ADDRESS=$(echo "$RESULT" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
    echo "Wallet created: $ADDRESS"
    echo "Keys are stored securely inside the node."
    ;;

  list)
    RESULT=$(rpc_call '{"jsonrpc":"2.0","method":"agent_listWallets","params":[],"id":1}')

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
