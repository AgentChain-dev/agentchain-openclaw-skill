#!/usr/bin/env bash
set -euo pipefail

# Mining control for AgentChain
# Usage: mine.sh start ADDRESS THREADS
#        mine.sh stop

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

COMMAND="${1:?Usage: mine.sh <start|stop> [ADDRESS THREADS]}"

case "$COMMAND" in
  start)
    ADDRESS="${2:?Usage: mine.sh start ADDRESS THREADS}"
    THREADS="${3:-1}"

    validate_address "$ADDRESS"

    RESULT=$(rpc_call "{\"jsonrpc\":\"2.0\",\"method\":\"agent_startMining\",\"params\":[\"$ADDRESS\",$THREADS],\"id\":1}")

    if echo "$RESULT" | grep -q '"error"'; then
      echo "Failed to start mining: $(echo "$RESULT" | grep -o '"message":"[^"]*"')" >&2
      exit 1
    fi

    echo "Mining started"
    echo "Address:  $ADDRESS"
    echo "Threads:  $THREADS"
    ;;

  stop)
    RESULT=$(rpc_call '{"jsonrpc":"2.0","method":"agent_stopMining","params":[],"id":1}')

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
