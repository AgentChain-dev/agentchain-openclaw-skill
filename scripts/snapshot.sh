#!/usr/bin/env bash
set -euo pipefail

# Download AgentChain chain snapshot for fast sync
# Usage: snapshot.sh [DATADIR]
#
# This downloads the latest chaindata snapshot and extracts it,
# skipping days/weeks of block-by-block syncing.
# IMPORTANT: geth must be stopped before running this.

SNAPSHOT_META="http://165.232.86.29/snapshot/snapshot.json"
SNAPSHOT_URL="http://165.232.86.29/snapshot/chaindata-latest.tar.gz"
RPC="${AGENTCHAIN_RPC:-http://165.232.86.29}"

# Default data directory per platform
if [ -n "${AGENTCHAIN_DATADIR:-}" ]; then
  DATADIR="$AGENTCHAIN_DATADIR"
elif [ -n "${1:-}" ]; then
  DATADIR="$1"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
  DATADIR="$APPDATA/AgentChain"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  DATADIR="$HOME/Library/Application Support/AgentChain"
else
  DATADIR="$HOME/.agentchain"
fi

# Determine chain subdirectory
if [ -d "$DATADIR/agentchain" ]; then
  CHAINDIR="$DATADIR/agentchain"
elif [ -d "$DATADIR/geth" ]; then
  CHAINDIR="$DATADIR/geth"
else
  # Fresh install — create agentchain dir
  CHAINDIR="$DATADIR/agentchain"
  mkdir -p "$CHAINDIR"
fi

# Check geth is not running
if pgrep -x geth > /dev/null 2>&1; then
  echo "Error: geth is still running. Stop it before downloading the snapshot." >&2
  echo "  Run: pkill geth  (or taskkill /F /IM geth.exe on Windows)" >&2
  exit 1
fi

# Show snapshot info
echo "=== AgentChain Snapshot Download ==="
META=$(curl -s "$SNAPSHOT_META" 2>/dev/null || echo "{}")
if echo "$META" | grep -q '"size"'; then
  SIZE=$(echo "$META" | grep -o '"size":[0-9]*' | cut -d: -f2)
  SIZE_MB=$((SIZE / 1048576))
  echo "Snapshot size: ${SIZE_MB} MB"
fi
if echo "$META" | grep -q '"timestamp"'; then
  TIMESTAMP=$(echo "$META" | grep -o '"timestamp":[0-9]*' | cut -d: -f2)
  echo "Snapshot date: $(date -d @"$TIMESTAMP" 2>/dev/null || date -r "$TIMESTAMP" 2>/dev/null || echo "$TIMESTAMP")"
fi
echo "Target: $CHAINDIR/chaindata"
echo ""

# Remove old chaindata
if [ -d "$CHAINDIR/chaindata" ]; then
  echo "Removing old chaindata..."
  rm -rf "$CHAINDIR/chaindata"
fi

# Download and extract in one step
echo "Downloading and extracting snapshot..."
curl -# -L "$SNAPSHOT_URL" | tar xzf - -C "$CHAINDIR"

echo ""
echo "Done! Chaindata extracted to $CHAINDIR/chaindata"
echo "You can now start geth."
