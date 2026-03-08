#!/usr/bin/env bash
set -euo pipefail

# Show AgentChain network status
# Usage: status.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

BLOCK=$(rpc_call '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')
PEERS=$(rpc_call '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}')
MINING=$(rpc_call '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":1}')
HASHRATE=$(rpc_call '{"jsonrpc":"2.0","method":"eth_hashrate","params":[],"id":1}')
SYNCING=$(rpc_call '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')

BLOCK_HEX=$(echo "$BLOCK" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
BLOCK_NUM=$(printf "%d" "$BLOCK_HEX" 2>/dev/null || echo "0")

PEERS_HEX=$(echo "$PEERS" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
PEERS_NUM=$(printf "%d" "$PEERS_HEX" 2>/dev/null || echo "0")

IS_MINING=$(echo "$MINING" | grep -o '"result":[a-z]*' | cut -d':' -f2)

HASH_HEX=$(echo "$HASHRATE" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
HASH_NUM=$(printf "%d" "$HASH_HEX" 2>/dev/null || echo "0")

IS_SYNCING=$(echo "$SYNCING" | grep -o '"result":false' > /dev/null && echo "false" || echo "true")

echo "=== AgentChain Network Status ==="
echo "RPC:       $RPC"
echo "Block:     #$BLOCK_NUM"
echo "Peers:     $PEERS_NUM"
echo "Mining:    $IS_MINING"
echo "Hashrate:  $HASH_NUM H/s"
echo "Syncing:   $IS_SYNCING"
echo "Chain ID:  7331"
echo "Currency:  CRD"
