# ERC-20 Token Example (Hardhat)

This example shows how to create and deploy an **ERC-20 token** on **Jovay Network** using **Hardhat**.

## Features

- **ERC-20 token**: Standard token implementation with 6 decimals
- **OpenZeppelin integration**: Uses battle-tested OpenZeppelin contracts
- **Deployment scripts**: Ready-to-use deployment script
- **Comprehensive tests**: Full test coverage for token functionality

## Network Configuration

| Network       | RPC URL                                  | Chain ID |
| ------------- | ---------------------------------------- | -------- |
| Jovay Mainnet | https://rpc.jovay.io                     | 5734951  |
| Jovay Testnet | https://api.zan.top/public/jovay-testnet | 2019775  |

## Prerequisites

- Node.js (v18 or later)
- npm or yarn
- Testnet funds: Jovay testnet gas token (get from [Faucet](https://docs.jovay.io))
- Access to Jovay Testnet RPC endpoint

## Installation

1. Navigate to the example directory:

```bash
cd jovay-examples/hardhat_examples/token_example
```

2. Install dependencies:

```bash
npm install
```

## Environment Setup

Create a `.env` file in the project root:

```bash
touch .env
```

Add your network RPC URLs and wallet private keys to the `.env` file:

```
# Testnet Configuration
JOVAY_TESTNET_RPC_URL="https://api.zan.top/public/jovay-testnet"
TESTNET_PRIVATE_KEY="YOUR_TESTNET_WALLET_PRIVATE_KEY"

# Mainnet Configuration (Optional)
# JOVAY_MAINNET_RPC_URL="https://rpc.jovay.io"
# MAINNET_PRIVATE_KEY="YOUR_MAINNET_WALLET_PRIVATE_KEY"
```

> **Important:** Never commit the `.env` file to version control. It contains sensitive information.

## Build & Test

```bash
npx hardhat compile
npx hardhat test
```

## Contracts

- **`MyToken.sol`**: ERC-20 token contract with 6 decimals, using OpenZeppelin's ERC20 implementation.

## Deploy the Token Contract

Deploy the contract to the desired network. This example uses the testnet:

```bash
npx hardhat run scripts/deploy.js --network jovay_testnet
```

If your script's execution succeeds, you should see the deployment transaction hash and contract address.

## Troubleshooting

- **Deployment fails?** Make sure your wallet has enough testnet tokens.
- **Can't interact with the contract?** Double-check the contract address and ABI.
- **Transfer fails?** Confirm your wallet has enough balance.

## Links

- [Jovay Documentation](https://docs.jovay.io)
- [Jovay Hardhat Token Tutorial](https://docs.jovay.io/guide/token-hardhat)
- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)

## License

MIT
