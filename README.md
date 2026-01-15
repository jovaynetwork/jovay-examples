# Jovay Examples

Open-source example projects, smart contract templates, and tutorials for building on **Jovay Network**.

## Overview

This repository hosts small, focused examples that you can copy, modify, and run locally. Each example is intended to be self-contained and includes its own README with prerequisites and step-by-step instructions.

## Repository layout

```
.
├── chainlink_examples/          # Chainlink-related examples
│   └── ccip_example/            # CCIP (Foundry): messaging + token transfer
├── foundry_examples/            # Foundry tutorial examples
│   ├── token_example/           # ERC-20 token (Foundry)
│   ├── nft_example/              # ERC-721 NFT (Foundry)
│   └── staking_example/         # Staking contract (Foundry)
├── hardhat_examples/            # Hardhat tutorial examples
│   ├── token_example/           # ERC-20 token (Hardhat)
│   ├── nft_example/             # ERC-721 NFT (Hardhat)
│   └── staking_example/         # Staking contract (Hardhat)
└── LICENSE
```

## Getting started

This repo uses **git submodules** for some examples (e.g. Foundry dependencies). For the smoothest first-time setup:

```bash
git clone --recurse-submodules https://github.com/jovaynetwork/jovay-examples.git
cd jovay-examples
```

If you already cloned the repo:

```bash
git submodule update --init --recursive
```

## Examples

### Chainlink

- **CCIP (Foundry)**: `chainlink_examples/ccip_example`
  - Cross-chain messaging and token transfers between **Ethereum Sepolia** and **Jovay Testnet**
  - See: `chainlink_examples/ccip_example/README.md`

### Foundry Tutorials

- **ERC-20 Token**: `foundry_examples/token_example`
  - Create and deploy your first token on Jovay using Foundry
  - See: `foundry_examples/token_example/README.md`

- **ERC-721 NFT**: `foundry_examples/nft_example`
  - Create and deploy your first NFT on Jovay using Foundry
  - See: `foundry_examples/nft_example/README.md`

- **Staking Contract**: `foundry_examples/staking_example`
  - Build and deploy a simple staking contract on Jovay using Foundry
  - See: `foundry_examples/staking_example/README.md`

### Hardhat Tutorials

- **ERC-20 Token**: `hardhat_examples/token_example`
  - Create and deploy your first token on Jovay using Hardhat
  - See: `hardhat_examples/token_example/README.md`

- **ERC-721 NFT**: `hardhat_examples/nft_example`
  - Create and deploy your first NFT on Jovay using Hardhat
  - See: `hardhat_examples/nft_example/README.md`

- **Staking Contract**: `hardhat_examples/staking_example`
  - Build and deploy a simple staking contract on Jovay using Hardhat
  - See: `hardhat_examples/staking_example/README.md`

## Documentation

- Jovay docs: `https://docs.jovay.io`

## Contributing

See `CONTRIBUTING.md`.

## Security

See `SECURITY.md`.

## License

MIT — see `LICENSE`.

## CI and examples registry

This repo uses `examples.yaml` as the single source of truth for examples metadata and CI.

- Add a new example by adding a new entry to `examples.yaml` (unique `path`, plus `type` and `description`).
- CI runs basic checks per example type:
  - **solidity (Foundry)**: `forge fmt --check`, `forge build`, `forge test` (optionally `--offline`).
  - **solidity (Hardhat)**: `npx hardhat compile`, `npx hardhat test`.
