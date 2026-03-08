#!/usr/bin/env bash
set -euo pipefail

# Health check for AgentChain RPC node
# Usage: health.sh
# Exit codes: 0 = healthy, 1 = unhealthy
# Useful for monitoring, cron jobs, or agent pre-flight checks

RPC="${AGENTCHAIN_RPC:-http://165.232.86.29}"
ERRORS=0

check() {
  local label="$1" method="$2"
  local result
  result=$(curl -s -w "\n%{http_code}" -X POST "$RPC" \
    -H "Content-Type: application/json" \
    --connect-timeout 3 --max-time 5 \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"$method\",\"params\":[],\"id\":1}" 2>/dev/null)

  local http_code
  http_code=$(echo "$result" | tail -1)
  result=$(echo "$result" | sed '$d')

  if [ "$http_code" = "200" ] && echo "$result" | grep -q '"result"'; then
    local val
    val=$(echo "$result" | grep -o '"result":[^,}]*' | cut -d: -f2 | tr -d '"')
    echo "  OK  $label: $val"
  else
    echo "  FAIL $label: HTTP $http_code"
    ERRORS=$((ERRORS + 1))
  fi
}

echo "=== AgentChain Health Check ==="
echo "RPC: $RPC"
echo ""

check "Block number" "eth_blockNumber"
check "Peer count" "net_peerCount"
check "Mining" "eth_mining"
check "Syncing" "eth_syncing"

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "Status: HEALTHY"
  exit 0
else
  echo "Status: UNHEALTHY ($ERRORS checks failed)"
  exit 1
fi
