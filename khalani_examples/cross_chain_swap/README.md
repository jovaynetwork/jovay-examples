# Khalani Cross-Chain Swap Example dApp

A modern, cross-chain swap example dApp built with React + Vite that enables ETH and USDC transfers between **Ethereum Mainnet** and **Jovay Network** using **Khalani Intent Markets**.

## Features

- **Intent-based Cross-Chain Swaps**: Use Khalani's innovative intent market architecture instead of traditional bridges
- **Bidirectional Support**: Swap from Ethereum → Jovay or Jovay → Ethereum
- **Multiple Tokens**: Support for ETH (native) and USDC (ERC-20)
- **Competitive Rates**: Multiple solvers compete to fulfill your intent, ensuring best prices
- **Atomic Execution**: Transactions either complete successfully or receive a full refund
- **Real-time Tracking**: Monitor order status from creation to fulfillment
- **Modern UI**: Clean, responsive interface built with React and Tailwind CSS

## Technology Stack

- **Frontend**: React 18 with TypeScript
- **Build Tool**: Vite
- **Styling**: Tailwind CSS
- **Blockchain Interaction**: EIP-1193 (MetaMask, WalletConnect compatible wallets)
- **API**: Khalani Intent Markets API (https://api.hyperstream.dev)

## Prerequisites

Before you begin, ensure you have:

- **Node.js** (v18 or higher) and npm/yarn/pnpm
- **An EIP-1193 compatible wallet** (e.g., MetaMask, Coinbase Wallet, Rainbow)
- **Test/Mainnet tokens**: ETH and/or USDC on either Ethereum or Jovay networks
- **Gas tokens**: Sufficient gas on both networks for transaction fees

## Network Configuration

| Network | Chain ID | RPC URL | Explorer |
|---------|-----------|----------|-----------|
| Ethereum Mainnet | 1 | https://rpc.ankr.com/eth | https://etherscan.io |
| Jovay Network | 5734951 | https://rpc.jovay.io | https://explorer.jovay.io |

### Token Addresses

| Token | Ethereum | Jovay |
|-------|----------|--------|
| ETH | Native (0xEeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) | Native |
| USDC/USDC.e | 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 | 0x0cb184F30CCAA14A8eF71ea8D9528812E64FcE9f (USDC.e) |

Notice: the USDC.e is deployed and managed by Khalani.

> **Note**: The USDC address on Jovay needs to be confirmed and updated in `src/config.ts`.

## Installation

### Clone the Repository

If you're cloning the repository for the first time:

```bash
git clone --recurse-submodules https://github.com/jovaynetwork/jovay-examples.git
cd jovay-examples/khalani_examples/cross_chain_swap/frontend
```

If you've already cloned:

```bash
cd jovay-examples
git submodule update --init --recursive
cd khalani_examples/cross_chain_swap/frontend
```

### Install Dependencies

```bash
npm install
# or
yarn install
# or
pnpm install
```

## Running the dApp

### Development Mode

Start the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
```

The dApp will be available at `http://localhost:3000`.

### Production Build

Build for production:

```bash
npm run build
```

Preview the production build:

```bash
npm run preview
```

## Usage Guide

### Step 1: Connect Your Wallet

1. Click the "Connect Wallet" button in the top-right corner
2. Select your preferred wallet (e.g., MetaMask)
3. Approve the connection request
4. Your wallet address will appear in the header

### Step 2: Select Networks and Tokens

1. **From Network**: Choose the source network (Ethereum or Jovay)
2. **To Network**: Choose the destination network (must be different from source)
3. **From Token**: Select ETH or USDC to swap
4. **To Token**: Select the desired output token

### Step 3: Enter Amount

1. Enter the amount you want to swap in the "Amount" field
2. Ensure you have sufficient balance for the amount plus gas fees
3. The amount will be automatically validated

### Step 4: Get a Quote

1. Click the "Get Quote" button
2. The dApp will request a quote from Khalani's intent market
3. Wait a few seconds for solvers to provide competitive rates
4. Review the quote details:
   - **Expected Output**: Amount you'll receive
   - **Est. Duration**: Time to complete the swap
   - **Valid Until**: Quote expiration time

### Step 5: Confirm and Execute Transaction

1. Click "Confirm Transaction"
2. If you're not on the source network, you'll be prompted to switch networks
3. If swapping USDC (ERC-20), approve the Khalani contract to spend your tokens
4. Execute the deposit transaction
5. Wait for the transaction to be confirmed

### Step 6: Track Your Order

After submitting:
1. An order tracker will appear showing your order status
2. The order goes through these stages:
   - **Created**: Your order has been submitted
   - **Deposited**: Your deposit transaction is confirmed
   - **Published**: Your order is available to solvers
   - **Filled**: A solver has fulfilled your order ✓

3. You can click on the transaction hash to view it on the block explorer
4. Once marked as "Filled", your cross-chain swap is complete!

### Step 7: Check Your Destination

1. Switch to the destination network in your wallet
2. Check your balance for the received tokens
3. View the transaction on the destination block explorer

## Understanding Khalani Intent Markets

### What is Intent-Based Architecture?

Traditional cross-chain bridges require you to lock funds on a source chain and burn/mint tokens on a destination chain. Khalani uses a different approach:

1. **Declare Intent**: You state what you want (e.g., "I want 1 ETH on Jovay for 1.05 ETH on Ethereum")
2. **Solver Competition**: Multiple independent solvers compete to fulfill your intent
3. **Best Price**: Solvers bid against each other, ensuring you get the best rate
4. **Atomic Execution**: The transaction either completes successfully OR refunds your funds in full

### Advantages

- **One Integration**: Access to 40+ chains through a single API
- **No Per-Chain Work**: New chains are automatically supported as solvers add them
- **Zero Stuck Funds**: Atomic execution or full refund
- **Future-Proof**: Your integration automatically gains new capabilities
- **Competitive Rates**: Solvers compete on every transaction

## Troubleshooting

### Wallet Connection Issues

**Problem**: "No Ethereum wallet found"
- **Solution**: Install MetaMask or another EIP-1193 compatible wallet

**Problem**: Wallet disconnects randomly
- **Solution**: Refresh the page and reconnect your wallet

### Network Switching Issues

**Problem**: "Network not found in wallet"
- **Solution**: The dApp will attempt to add the network automatically. Approve the network addition request.

**Problem**: Chain ID mismatch
- **Solution**: Ensure you're on the correct source network before initiating a swap

### Transaction Failures

**Problem**: "Insufficient funds"
- **Solution**: Ensure you have enough tokens AND gas fees for the transaction

**Problem**: "Quote expired"
- **Solution**: Request a new quote. Quotes are valid for a limited time.

**Problem**: USDC approval fails
- **Solution**: Try increasing the gas limit or wait for network congestion to decrease.

### Order Status Issues

**Problem**: Order stuck at "Published"
- **Solution**: Wait a bit longer. Solvers may take time to fulfill, especially for large amounts or less common routes.

**Problem**: Order marked as "Refunded"
- **Solution**: Your funds have been refunded to your source wallet. Check your balance and try again with a new quote.

## API Reference

The dApp uses the Khalani Intent Markets API:

### Base URL
```
https://api.hyperstream.dev
```

### Endpoints

#### Request Quote
```http
POST /v1/quotes
Content-Type: application/json

{
  "fromAddress": "0x...",
  "tradeType": "EXACT_INPUT",
  "fromChainId": 1,
  "fromToken": "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  "toChainId": 5734951,
  "toToken": "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE",
  "amount": "1000000"
}
```

#### Build Deposit Plan
```http
POST /v1/deposit/build
Content-Type: application/json

{
  "from": "0x...",
  "quoteId": "...",
  "routeId": "..."
}
```

#### Submit Deposit
```http
PUT /v1/deposit/submit
Content-Type: application/json

{
  "txHash": "0x...",
  "quoteId": "...",
  "routeId": "..."
}
```

#### Get Order Status
```http
GET /v1/orders/{address}?orderIds={orderId}
```

For full API documentation, visit [Khalani Docs](https://docs.khalani.io).

## Project Structure

```
frontend/
├── src/
│   ├── components/          # React components
│   │   ├── ChainSelector.tsx
│   │   ├── TokenSelector.tsx
│   │   ├── SwapForm.tsx
│   │   ├── OrderTracker.tsx
│   │   └── WalletProvider.tsx
│   ├── hooks/              # Custom React hooks
│   │   ├── useKhalaniAPI.ts
│   │   └── useWallet.ts
│   ├── lib/                # Utility libraries
│   │   └── khalani.ts
│   ├── types/              # TypeScript type definitions
│   │   └── index.ts
│   ├── config.ts           # Configuration and constants
│   ├── App.tsx            # Main application
│   ├── main.tsx           # Entry point
│   └── index.css          # Global styles
├── public/                # Static assets
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.js
└── postcss.config.js
```

## Customization

### Adding New Networks

Edit `src/config.ts` and add a new network configuration:

```typescript
export const NETWORKS = {
  // ... existing networks
  NEW_NETWORK: {
    chainId: 12345,
    name: 'New Network',
    rpcUrl: 'https://rpc.example.com',
    explorer: 'https://explorer.example.com',
    nativeCurrency: { name: 'Native', symbol: 'ETH', decimals: 18 },
    usdcAddress: '0x...'
  }
};
```

### Adding New Tokens

Edit `src/config.ts` and add a new token factory:

```typescript
export const TOKENS = {
  // ... existing tokens
  NEW_TOKEN: (network: Network): Token => ({
    symbol: 'NEW',
    name: 'New Token',
    address: '0x...', // Replace with actual address
    decimals: 18,
    isNative: false
  })
};
```

### Styling

The dApp uses Tailwind CSS. Customize the design by modifying component classes or the global `tailwind.config.js`.

## Security Considerations

- **Never share your private keys** or seed phrases
- **Always verify transaction details** before confirming in your wallet
- **Check contract addresses** in the block explorer before approving
- **Use official wallets** from trusted sources
- **Report bugs** responsibly via GitHub issues or Discord

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## Resources

- **Khalani Documentation**: https://docs.khalani.io
- **Khalani Quick Start**: https://khalani.gitbook.io/khalani-docs/integration-guide/quick-start-5-minutes
- **Jovay Network**: https://docs.jovay.io
- **React Documentation**: https://react.dev
- **Vite Documentation**: https://vitejs.dev
- **Tailwind CSS**: https://tailwindcss.com

## License

MIT License - see LICENSE file for details

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Search [existing GitHub issues](https://github.com/your-org/jovay-examples/issues)
3. Join the [Khalani Discord](https://discord.gg/khalani)
4. Reach out on [Jovay Discord](https://discord.gg/jovay)

## Acknowledgments

- Built with [Khalani Intent Markets](https://khalani.network)
- Powered by [Jovay Network](https://jovay.network)
- UI inspired by modern DeFi interfaces
