# ERC-20 Token Example (Foundry)

This example shows how to create and deploy an **ERC-20 token** on **Jovay Network** using **Foundry**.

## Features

- **ERC-20 token**: Standard token implementation with 6 decimals
- **OpenZeppelin integration**: Uses battle-tested OpenZeppelin contracts
- **Deployment scripts**: Ready-to-use deployment and interaction scripts
- **Comprehensive tests**: Full test coverage for token functionality

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
cd jovay-examples/foundry_examples/token_example
```

If you already cloned the repo:

```bash
cd jovay-examples
git submodule update --init --recursive
cd foundry_examples/token_example
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

## Deploy the Token Contract

1. Deploy the contract:

```bash
forge script script/DeployToken.s.sol --rpc-url $RPC_URL --broadcast
```

If your script's execution succeeds, you should see the deployment transaction hash and contract address.

## Interact with the Token Contract

1. Set additional environment variables:

```bash
export TOKEN_ADDRESS=<YOUR_DEPLOYED_TOKEN_ADDRESS>
export RECIPIENT_ADDRESS=<RECIPIENT_ADDRESS>
export AMOUNT=1000000  # Amount in token units (with 6 decimals)
```

2. Execute the interaction script:

```bash
forge script script/InteractToken.s.sol --rpc-url $RPC_URL --broadcast
```

## Troubleshooting

- **Deployment fails?** Make sure your wallet has enough testnet tokens.
- **Can't interact with the contract?** Double-check the contract address and ABI.
- **Transfer fails?** Confirm your wallet has enough balance.

## Links

- [Jovay Documentation](https://docs.jovay.io)
- [Jovay Foundry Token Tutorial](https://docs.jovay.io/guide/token-foundry)
- [Foundry Documentation](https://book.getfoundry.sh)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)

## License

MIT
