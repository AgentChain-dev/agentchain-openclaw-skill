---
name: agentchain
description: "Interact with the AgentChain blockchain (Chain ID 7331). Use when the user or agent needs to: send or receive CRD tokens, check wallet balances, create wallets, start or stop mining, check network status, or make on-chain payments. AgentChain is an EVM-compatible L1 built for AI agent payments using RandomX proof-of-work."
version: 1.0.0
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

### Network Configuration

| Property | Value |
|----------|-------|
| Chain ID | 7331 |
| Currency | CRD |
| Public RPC | `http://165.232.86.29:8545` |
| Block time | ~15 seconds |
| Consensus | RandomX Proof-of-Work |
| Block reward | 2 CRD |

The default RPC endpoint is `http://165.232.86.29:8545`. Override with the `AGENTCHAIN_RPC` environment variable for a local node (e.g. `http://127.0.0.1:8545`).

### Available Commands

All commands use JSON-RPC over HTTP. Use curl to make calls.

#### Check Balance

```bash
RESULT=$(curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getBalance","params":["ADDRESS","latest"],"id":1}')
```

The result is in hex wei. Convert to CRD by dividing by 10^18.

#### Send CRD (Transfer)

To send CRD from one address to another, the sending account must be unlocked on the node. Use the `agent_sendTransaction` method:

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from":"SENDER","to":"RECIPIENT","value":"VALUE_IN_HEX_WEI"}],"id":1}'
```

To convert CRD to wei hex: multiply CRD amount by 10^18, then convert to hex with `0x` prefix. For example, 1 CRD = `0xDE0B6B3A7640000`.

#### Create a New Wallet

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"personal_newAccount","params":["PASSWORD"],"id":1}'
```

Returns the new wallet address. Store the password securely — it is needed to unlock the account for sending.

#### List Accounts

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}'
```

#### Unlock Account (required before sending)

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"personal_unlockAccount","params":["ADDRESS","PASSWORD",300],"id":1}'
```

The third parameter is unlock duration in seconds.

#### Get Current Block Number

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

#### Get Peer Count

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
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
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":1}'
```

#### Get Hashrate

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_hashrate","params":[],"id":1}'
```

#### Get Transaction Receipt

```bash
curl -s -X POST "${AGENTCHAIN_RPC:-http://165.232.86.29:8545}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["TX_HASH"],"id":1}'
```

### Helper Scripts

The `scripts/` directory contains helper scripts:

- **`scripts/balance.sh ADDRESS`** — Get CRD balance for an address (human-readable)
- **`scripts/send.sh FROM TO AMOUNT_CRD PASSWORD`** — Send CRD between accounts
- **`scripts/status.sh`** — Show network status (block height, peers, sync state)
- **`scripts/wallet.sh create PASSWORD`** — Create a new wallet
- **`scripts/wallet.sh list`** — List all accounts
- **`scripts/mine.sh start ADDRESS THREADS`** — Start mining
- **`scripts/mine.sh stop`** — Stop mining

### Usage Patterns

#### Agent-to-Agent Payment

When an AI agent needs to pay another agent in CRD:

1. Check balance: `scripts/balance.sh YOUR_ADDRESS`
2. Unlock account: use `personal_unlockAccount` with your password
3. Send payment: `scripts/send.sh YOUR_ADDRESS RECIPIENT_ADDRESS AMOUNT PASSWORD`
4. Verify: check the transaction receipt with the returned tx hash

#### Earning CRD by Mining

If the agent has access to a local AgentChain node:

1. Create a wallet: `scripts/wallet.sh create mypassword`
2. Start mining: `scripts/mine.sh start WALLET_ADDRESS 2`
3. Check earnings: `scripts/balance.sh WALLET_ADDRESS`

### Rules

- Always confirm with the user before sending CRD or creating wallets.
- Never log or display private keys or passwords in output.
- Use the public RPC (`http://165.232.86.29:8545`) for read operations by default.
- Mining and account management require a local node — these will fail on the public RPC.
- All hex values from the RPC are prefixed with `0x`. Parse them as hexadecimal.
- 1 CRD = 10^18 wei (same as ETH/wei relationship).

### Security & Privacy

- This skill only communicates with the AgentChain RPC endpoint (default: `http://165.232.86.29:8545` or user-configured `AGENTCHAIN_RPC`).
- No data is sent to any third-party service.
- Wallet passwords are only used in RPC calls to the configured node and are never stored by the skill.
- Scripts use `set -euo pipefail` for safe execution.
