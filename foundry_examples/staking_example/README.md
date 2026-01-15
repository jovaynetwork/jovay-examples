# Staking Contract Example (Foundry)

This example shows how to build and deploy a basic **token staking contract** on **Jovay Network** using **Foundry**.

## Features

- **ERC-20 token**: Mintable token for staking
- **Staking contract**: Time-based reward staking system
- **Core functions**: Stake, claim rewards, and withdraw tokens
- **OpenZeppelin integration**: Uses battle-tested OpenZeppelin contracts
- **Deployment scripts**: Ready-to-use deployment and interaction scripts
- **Comprehensive tests**: Full test coverage for staking functionality

## Network Configuration

| Network       | RPC URL                                  | Chain ID |
| ------------- | ---------------------------------------- | -------- |
| Jovay Mainnet | https://rpc.jovay.io                     | 5734951  |
| Jovay Testnet | https://api.zan.top/public/jovay-testnet | 2019775  |

## Prerequisites

- Git
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Testnet funds: Jovay testnet gas token (get from [Faucet](https://docs.jovay.io))
- Access to Jovay Testnet RPC endpoint

## Installation

From a fresh clone (recommended):

```bash
git clone --recurse-submodules <REPO_URL>
cd jovay-examples/foundry_examples/staking_example
```

If you already cloned the repo:

```bash
cd jovay-examples
git submodule update --init --recursive
cd foundry_examples/staking_example
```

## Environment Setup

Set environment variables in your shell:

For **Testnet**:

```bash
export PRIVATE_KEY="YOUR_TESTNET_WALLET_PRIVATE_KEY"
export RPC_URL="https://api.zan.top/public/jovay-testnet"
```

For **Mainnet**:

```bash
export PRIVATE_KEY="YOUR_MAINNET_WALLET_PRIVATE_KEY"
export RPC_URL="https://rpc.jovay.io"
```

> **Tip:** For a more permanent solution, you can add these `export` lines to your shell's profile file (e.g., `.bashrc`, `.zshrc`) or save them in a `.env` file and run `source .env` in your terminal before you start working.

## Build & Test

```bash
forge build
forge test --offline
```

Notes:
- `--offline` avoids network access and works around a known Foundry macOS crash related to system proxy detection.

## Contracts

- **`MyToken.sol`**: ERC-20 token contract with 6 decimals, using OpenZeppelin's ERC20 implementation.
- **`SimpleStaking.sol`**: Staking contract that rewards users over time based on their staked amount.

## Deploy the Contracts

### 1. Deploy the Token Contract

```bash
forge script script/DeployMyToken.s.sol --rpc-url $RPC_URL --broadcast
```

Record the deployed token address.

### 2. Deploy the Staking Contract

Set the token address:

```bash
export TOKEN_ADDRESS=<YOUR_DEPLOYED_TOKEN_ADDRESS>
```

Deploy the staking contract:

```bash
forge script script/DeploySimpleStaking.s.sol --rpc-url $RPC_URL --broadcast
```

Record the deployed staking contract address.

## Interact with the Staking Contract

1. Set additional environment variables:

```bash
export STAKING_ADDRESS=<YOUR_DEPLOYED_STAKING_ADDRESS>
```

2. Execute the interaction script:

```bash
forge script script/InteractSimpleStaking.s.sol --rpc-url $RPC_URL --broadcast
```

The script will:
- Approve and stake tokens
- Transfer tokens to the staking contract as a reward pool
- Withdraw staked tokens

## Troubleshooting

- **Deployment fails?** Make sure your wallet has enough testnet tokens.
- **Staking fails?** Confirm that the token is approved before staking.
- **Rewards not updating?** Make sure you're calling `_update()` before checking balances.

## Links

- [Jovay Documentation](https://docs.jovay.io)
- [Jovay Foundry Staking Tutorial](https://docs.jovay.io/guide/contract-foundry)
- [Foundry Documentation](https://book.getfoundry.sh)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)

## License

MIT
