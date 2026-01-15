# Staking Contract Example (Hardhat)

This example shows how to build and deploy a basic **token staking contract** on **Jovay Network** using **Hardhat**.

## Features

- **ERC-20 token**: Mintable token for staking
- **Staking contract**: Time-based reward staking system
- **Core functions**: Stake, claim rewards, and withdraw tokens
- **OpenZeppelin integration**: Uses battle-tested OpenZeppelin contracts
- **Deployment scripts**: Ready-to-use deployment script
- **Comprehensive tests**: Full test coverage for staking functionality

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
cd jovay-examples/hardhat_examples/staking_example
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
- **`SimpleStaking.sol`**: Staking contract that rewards users over time based on their staked amount.

## Deploy the Contracts

Deploy the contracts to the desired network. This example uses the testnet:

```bash
npx hardhat run scripts/deploy.js --network jovay_testnet
```

The script will deploy both the token and staking contracts. You should see the deployment transaction hashes and contract addresses.

## Troubleshooting

- **Deployment fails?** Make sure your wallet has enough testnet tokens.
- **Staking fails?** Confirm that the token is approved before staking.
- **Rewards not updating?** Make sure you're calling `_update()` before checking balances.

## Links

- [Jovay Documentation](https://docs.jovay.io)
- [Jovay Hardhat Staking Tutorial](https://docs.jovay.io/guide/contract-hardhat)
- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)

## License

MIT
