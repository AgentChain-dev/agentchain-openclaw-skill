#!/usr/bin/env bash
set -euo pipefail

# Mining control for AgentChain
# Usage: mine.sh start ADDRESS THREADS
#        mine.sh stop

RPC="${AGENTCHAIN_RPC:-http://127.0.0.1:8545}"
COMMAND="${1:?Usage: mine.sh <start|stop> [ADDRESS THREADS]}"

case "$COMMAND" in
  start)
    ADDRESS="${2:?Usage: mine.sh start ADDRESS THREADS}"
    THREADS="${3:-1}"

    if [[ ! "$ADDRESS" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
      echo "Error: Invalid address format." >&2
      exit 1
    fi

    RESULT=$(curl -s -X POST "$RPC" \
      -H "Content-Type: application/json" \
      -d "{\"jsonrpc\":\"2.0\",\"method\":\"agent_startMining\",\"params\":[\"$ADDRESS\",$THREADS],\"id\":1}")

    if echo "$RESULT" | grep -q '"error"'; then
      echo "Failed to start mining: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
      exit 1
    fi

    echo "Mining started"
    echo "Address:  $ADDRESS"
    echo "Threads:  $THREADS"
    ;;

  stop)
    RESULT=$(curl -s -X POST "$RPC" \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","method":"agent_stopMining","params":[],"id":1}')

    if echo "$RESULT" | grep -q '"error"'; then
      echo "Failed to stop mining: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
      exit 1
    fi

    echo "Mining stopped"
    ;;

  *)
    echo "Unknown command: $COMMAND" >&2
    echo "Usage: mine.sh <start|stop> [ADDRESS THREADS]" >&2
    exit 1
    ;;
esac
