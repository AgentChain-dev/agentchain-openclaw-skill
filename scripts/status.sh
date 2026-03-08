#!/usr/bin/env bash
set -euo pipefail

# Show AgentChain network status
# Usage: status.sh

RPC="${AGENTCHAIN_RPC:-http://165.232.86.29:8545}"

# Fetch all status info in parallel
BLOCK=$(curl -s -X POST "$RPC" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')

PEERS=$(curl -s -X POST "$RPC" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}')

MINING=$(curl -s -X POST "$RPC" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":1}')

HASHRATE=$(curl -s -X POST "$RPC" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_hashrate","params":[],"id":1}')

SYNCING=$(curl -s -X POST "$RPC" -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}')

# Parse values
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
