# AgentChain Skill for OpenClaw

An [OpenClaw](https://github.com/openclaw-ai/openclaw) skill that lets AI agents interact with the **AgentChain** blockchain — an EVM-compatible L1 designed for AI agent payments.

## What is AgentChain?

AgentChain is a purpose-built blockchain for AI agent economies. It uses RandomX proof-of-work (CPU-mineable) and supports agent-to-agent payments in **CRD** tokens. Keys never leave the node — all signing is done internally via the `agent_*` API.

| Property | Value |
|----------|-------|
| Chain ID | 7331 |
| Currency | CRD |
| Consensus | RandomX PoW |
| Block time | ~6 seconds |
| Block reward | 2 CRD |

## Installation

### Via ClawHub

```
/install agentchain
```

### Manual

Clone this repo into your OpenClaw skills directory:

```bash
git clone https://github.com/AgentChain-dev/agentchain-openclaw-skill.git ~/.openclaw/skills/agentchain
```

## What Can Agents Do?

- **Check balances** — Query any address for its CRD balance
- **Send CRD** — Transfer tokens between accounts (no passwords needed)
- **Create wallets** — Generate new addresses on the fly (keys stay in node)
- **Deploy contracts** — Deploy smart contracts to the chain
- **Call contracts** — Interact with deployed contracts
- **Mine CRD** — Earn tokens by contributing CPU power (local node required)
- **Monitor network** — Check block height, peers, sync status, hashrate

## Requirements

- `curl` (available on all major platforms)
- Optional: A local AgentChain node (`geth`) for mining, wallet creation, and sending

## Configuration

Set the `AGENTCHAIN_RPC` environment variable to point to your node:

```bash
export AGENTCHAIN_RPC=http://127.0.0.1:8545
```

If not set, the public RPC (`http://165.232.86.29`) is used for read operations.

## Helper Scripts

| Script | Description |
|--------|-------------|
| `scripts/balance.sh ADDRESS` | Get CRD balance (human-readable) |
| `scripts/send.sh FROM TO AMOUNT` | Send CRD (no password needed) |
| `scripts/status.sh` | Show network status |
| `scripts/wallet.sh create` | Create a new wallet |
| `scripts/wallet.sh list` | List all wallets |
| `scripts/mine.sh start ADDRESS THREADS` | Start mining |
| `scripts/mine.sh stop` | Stop mining |
| `scripts/snapshot.sh [DATADIR]` | Download chain snapshot (fast sync) |
| `scripts/health.sh` | Health check (exit 0/1) |

## Links

- [AgentChain Website](https://agentchain.dev)
- [Block Explorer](https://agentchain.dev/explorer)
- [Documentation](https://agentchain.dev/docs)
- [GitHub](https://github.com/AgentChain-dev/agentchain)
- [Download Miner](https://github.com/AgentChain-dev/agentchain/releases)

## License

MIT
