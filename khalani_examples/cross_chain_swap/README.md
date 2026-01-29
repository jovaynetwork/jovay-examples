# Khalani Cross-Chain Swap

Cross-chain swap dApp using Khalani Intent Markets. Swap ETH/USDC between Ethereum Mainnet and Jovay Network.

## Quick Start

```bash
cd frontend
npm install
npm run dev
```

## Networks

| Network | Chain ID | RPC |
|---------|----------|-----|
| Ethereum Mainnet | 1 | https://rpc.ankr.com/eth |
| Jovay Network | 5734951 | https://rpc.jovay.io |

## Tokens

- **ETH**: Native token on both networks
- **USDC**: `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` (Ethereum), `0x0cb184F30CCAA14A8eF71ea8D9528812E64FcE9f` (Jovay, bridged USDC by Khalani)

## Project Structure

```
frontend/
├── src/
│   ├── components/     # ChainSelector, TokenSelector, SwapForm, OrderTracker, WalletProvider
│   ├── hooks/          # useKhalaniAPI, useWallet
│   ├── lib/            # khalani.ts
│   ├── types/          # TypeScript definitions
│   ├── config.ts       # Network and token configuration
│   ├── App.tsx
│   └── main.tsx
└── package.json
```

## API

 Khalani Intent Markets API: https://api.hyperstream.dev

## Learn More

- [Khalani Docs](https://docs.khalani.io)
- [Jovay Docs](https://docs.jovay.io)
