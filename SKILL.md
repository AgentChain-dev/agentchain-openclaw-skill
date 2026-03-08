---
name: agentchain
description: "Interact with the AgentChain blockchain (Chain ID 7331). Use when the user or agent needs to: send or receive CRD tokens, check wallet balances, create wallets, start or stop mining, check network status, or make on-chain payments. AgentChain is an EVM-compatible L1 built for AI agent payments using RandomX proof-of-work. Keys never leave the node — all signing is done internally via the agent_* API."
version: 1.1.0
homepage: https://github.com/AgentChain-dev/agentchain-openclaw-skill
user-invocable: true
command-dispatch: "tool"
command-tool: "run_terminal_cmd"
command-arg-mode: "raw"
metadata:
  clawdbot:
    emoji: "link"
    always: false
    os: ["darwin", "linux", "win32"]
    requires:
      anyBins:
        - curl
        - wget
    primaryEnv: AGENTCHAIN_RPC
    install:
      - id: geth
        kind: download
        url: https://github.com/AgentChain-dev/agentchain/releases
        bins: ["geth"]
        label: "Download AgentChain geth binary"
---

## AgentChain Skill

This skill lets you interact with the AgentChain blockchain — an EVM-compatible L1 designed for AI agent payments. Currency: **CRD**. Chain ID: **7331**.

Keys never leave the node. All signing and account management is done through the `agent_*` API — no passwords or private keys are exposed in RPC calls.

### Network Configuration

| Property | Value |
|----------|-------|
| Chain ID | 7331 |
| Currency | CRD |
| Public RPC | `http://165.232.86.29` |
| Block time | ~6 seconds |
| Consensus | RandomX Proof-of-Work |
| Block reward | 2 CRD |

The default RPC endpoint is `http://165.232.86.29`. Override with the `AGENTCHAIN_RPC` environment variable for a local node (e.g. `http://127.0.0.1:8545`).

### Available Commands

All commands use JSON-RPC over HTTP. Use curl to make calls.

#### Check Balance

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_getBalance","params":["ADDRESS"],"id":1}'
```

Returns the balance in wei (hex). Convert to CRD by dividing by 10^18.

You can also use the standard `eth_getBalance`:

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getBalance","params":["ADDRESS","latest"],"id":1}'
```

#### Send CRD (Transfer)

Use `agent_send` — the node signs internally, no keys are exposed:

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_send","params":["SENDER","RECIPIENT","VALUE_IN_HEX_WEI"],"id":1}'
```

To convert CRD to wei hex: multiply CRD amount by 10^18, then convert to hex with `0x` prefix. For example, 1 CRD = `0xDE0B6B3A7640000`.

#### Create a New Wallet

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_createWallet","params":[],"id":1}'
```

Returns the new wallet address. No password needed — keys are managed securely inside the node.

#### List Wallets

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_listWallets","params":[],"id":1}'
```

#### Get Current Block Number

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

#### Get Peer Count

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}'
```

#### Start Mining (local node only)

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://127.0.0.1:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_startMining","params":["ETHERBASE_ADDRESS",THREADS],"id":1}'
```

Replace `THREADS` with the number of CPU threads to use (e.g. `2`).

#### Stop Mining (local node only)

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://127.0.0.1:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_stopMining","params":[],"id":1}'
```

#### Get Mining Status

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":1}'
```

#### Get Hashrate

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_hashrate","params":[],"id":1}'
```

#### Deploy Contract

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://127.0.0.1:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_deployContract","params":["FROM_ADDRESS","BYTECODE","VALUE_HEX"],"id":1}'
```

Returns the transaction hash. Use `agent_getTransactionReceipt` to get the deployed contract address.

#### Call Contract

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_callContract","params":["TO_CONTRACT","ABI_ENCODED_DATA"],"id":1}'
```

#### Get Transaction Receipt

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"agent_getTransactionReceipt","params":["TX_HASH"],"id":1}'
```

#### Download Chain Snapshot (Fast Sync)

Instead of syncing block-by-block (which can take hours), download the latest chaindata snapshot:

```bash
# 1. Stop geth first
pkill geth  # or: taskkill /F /IM geth.exe on Windows

# 2. Check snapshot info
curl -s http://165.232.86.29/snapshot/snapshot.json

# 3. Download and extract to your data directory
CHAINDIR="$HOME/.agentchain/agentchain"  # adjust per OS
mkdir -p "$CHAINDIR"
rm -rf "$CHAINDIR/chaindata"
curl -L http://165.232.86.29/snapshot/chaindata-latest.tar.gz | tar xzf - -C "$CHAINDIR"

# 4. Start geth again
```

Data directory locations per platform:
- **Linux**: `~/.agentchain/agentchain/chaindata`
- **macOS**: `~/Library/Application Support/AgentChain/agentchain/chaindata`
- **Windows**: `%APPDATA%\AgentChain\agentchain\chaindata`

Or use the helper script: `scripts/snapshot.sh`

### Helper Scripts

The `scripts/` directory contains helper scripts:

- **`scripts/balance.sh ADDRESS`** — Get CRD balance for an address (human-readable)
- **`scripts/send.sh FROM TO AMOUNT_CRD`** — Send CRD between accounts (no password needed)
- **`scripts/status.sh`** — Show network status (block height, peers, sync state)
- **`scripts/wallet.sh create`** — Create a new wallet (no password needed)
- **`scripts/wallet.sh list`** — List all wallets with addresses
- **`scripts/mine.sh start ADDRESS THREADS`** — Start mining
- **`scripts/mine.sh stop`** — Stop mining
- **`scripts/snapshot.sh [DATADIR]`** — Download chain snapshot for fast sync
- **`scripts/health.sh`** — Health check (exit 0 = healthy, exit 1 = unhealthy)

### Usage Patterns

#### Agent-to-Agent Payment

When an AI agent needs to pay another agent in CRD:

1. Check balance: `scripts/balance.sh YOUR_ADDRESS`
2. Send payment: `scripts/send.sh YOUR_ADDRESS RECIPIENT_ADDRESS AMOUNT`
3. Verify: check the transaction receipt with the returned tx hash

No passwords or key management needed — the node handles signing internally.

#### Earning CRD by Mining

If the agent has access to a local AgentChain node:

1. Create a wallet: `scripts/wallet.sh create`
2. Start mining: `scripts/mine.sh start WALLET_ADDRESS 2`
3. Check earnings: `scripts/balance.sh WALLET_ADDRESS`

### Rules

- Always confirm with the user before sending CRD or creating wallets.
- Never log or display private keys in output.
- Use the public RPC (`http://165.232.86.29`) for read operations by default.
- Mining, wallet creation, and sending require a local node — these will fail on the public RPC.
- All hex values from the RPC are prefixed with `0x`. Parse them as hexadecimal.
- 1 CRD = 10^18 wei (same as ETH/wei relationship).
- Use `agent_*` methods instead of `personal_*` — the personal namespace is disabled by design.

### Security & Privacy

- Keys never leave the node. All signing happens internally via the `agent_*` API.
- No passwords are needed — wallet management is handled securely by the node.
- This skill only communicates with the AgentChain RPC endpoint (default: `http://165.232.86.29` or user-configured `AGENTCHAIN_RPC`).
- No data is sent to any third-party service.
- Scripts use `set -euo pipefail` for safe execution.
