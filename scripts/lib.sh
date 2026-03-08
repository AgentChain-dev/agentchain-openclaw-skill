#!/usr/bin/env bash
# Shared helper functions for AgentChain scripts

RPC="${AGENTCHAIN_RPC:-http://165.232.86.29}"

# RPC call with retry + exponential backoff
# Usage: rpc_call '{"jsonrpc":"2.0","method":"...","params":[...],"id":1}'
# Returns the JSON response. Retries on 429 and connection errors.
rpc_call() {
  local body="$1"
  local max_retries="${2:-5}"
  local delay=1

  for i in $(seq 1 "$max_retries"); do
    local http_code response
    response=$(curl -s -w "\n%{http_code}" -X POST "$RPC" \
      -H "Content-Type: application/json" \
      --connect-timeout 5 --max-time 10 \
      -d "$body")

    http_code=$(echo "$response" | tail -1)
    response=$(echo "$response" | sed '$d')

    if [ "$http_code" = "200" ]; then
      echo "$response"
      return 0
    elif [ "$http_code" = "429" ]; then
      echo "Rate limited (429), retrying in ${delay}s... (attempt $i/$max_retries)" >&2
    elif [ "$http_code" = "000" ]; then
      echo "Connection failed, retrying in ${delay}s... (attempt $i/$max_retries)" >&2
    else
      echo "HTTP $http_code, retrying in ${delay}s... (attempt $i/$max_retries)" >&2
    fi

    sleep "$delay"
    delay=$((delay * 2))
    if [ "$delay" -gt 16 ]; then delay=16; fi
  done

  echo "Error: RPC request failed after $max_retries attempts" >&2
  return 1
}

# Validate Ethereum address format
validate_address() {
  local addr="$1"
  if [[ ! "$addr" =~ ^0x[0-9a-fA-F]{40}$ ]]; then
    echo "Error: Invalid address format: $addr" >&2
    return 1
  fi
}
