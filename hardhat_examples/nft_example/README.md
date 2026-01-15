# ERC-721 NFT Example (Hardhat)

This example shows how to create and deploy your own **ERC-721 NFT** on **Jovay Network** using **Hardhat**.

## Features

- **ERC-721 NFT**: Standard NFT implementation with custom tokenURI storage
- **Ownable**: Access control for minting functionality
- **OpenZeppelin integration**: Uses battle-tested OpenZeppelin contracts
- **Deployment scripts**: Ready-to-use deployment script
- **Comprehensive tests**: Full test coverage for NFT functionality

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
cd jovay-examples/hardhat_examples/nft_example
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

- **`MyNFT.sol`**: ERC-721 NFT contract with Ownable access control and custom tokenURI storage.

## Deploy the NFT Contract

Deploy the contract to the desired network. This example uses the testnet:

```bash
npx hardhat run scripts/deploy.js --network jovay_testnet
```

If your script's execution succeeds, you should see the deployment transaction hash and contract address.

## Troubleshooting

- **Deployment fails?** Make sure your wallet has enough testnet tokens.
- **Minting fails?** Confirm that you're the owner and calling from the correct address.
- **Can't interact with the contract?** Double-check the contract address and ABI.

## Links

- [Jovay Documentation](https://docs.jovay.io)
- [Jovay Hardhat NFT Tutorial](https://docs.jovay.io/guide/nft-hardhat)
- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)

## License

MIT
