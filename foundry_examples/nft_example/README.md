# ERC-721 NFT Example (Foundry)

This example shows how to create and deploy your own **ERC-721 NFT** on **Jovay Network** using **Foundry**.

## Features

- **ERC-721 NFT**: Standard NFT implementation with custom tokenURI storage
- **Ownable**: Access control for minting functionality
- **OpenZeppelin integration**: Uses battle-tested OpenZeppelin contracts
- **Deployment scripts**: Ready-to-use deployment and interaction scripts
- **Comprehensive tests**: Full test coverage for NFT functionality

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
cd jovay-examples/foundry_examples/nft_example
```

If you already cloned the repo:

```bash
cd jovay-examples
git submodule update --init --recursive
cd foundry_examples/nft_example
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

- **`MyNFT.sol`**: ERC-721 NFT contract with Ownable access control and custom tokenURI storage.

## Deploy the NFT Contract

1. Deploy the contract:

```bash
forge script script/DeployMyNFT.s.sol --rpc-url $RPC_URL --broadcast
```

If your script's execution succeeds, you should see the deployment transaction hash and contract address.

## Interact with the NFT Contract

1. Set additional environment variables:

```bash
export NFT_ADDRESS=<YOUR_DEPLOYED_NFT_ADDRESS>
export RECIPIENT_ADDRESS=<RECIPIENT_ADDRESS>
export TOKEN_URI="ipfs://QmTTrwbe7Y1GM8qj1sZjKKR73Fz7V9V3aXjJ1o7pLjJDgM"  # Example IPFS URI
```

2. Execute the interaction script:

```bash
forge script script/InteractMyNFT.s.sol --rpc-url $RPC_URL --broadcast
```

## Troubleshooting

- **Deployment fails?** Make sure your wallet has enough testnet tokens.
- **Minting fails?** Confirm that you're the owner and calling from the correct address.
- **Can't interact with the contract?** Double-check the contract address and ABI.

## Links

- [Jovay Documentation](https://docs.jovay.io)
- [Jovay Foundry NFT Tutorial](https://docs.jovay.io/guide/nft-foundry)
- [Foundry Documentation](https://book.getfoundry.sh)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)

## License

MIT
