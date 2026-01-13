# Chainlink CCIP Example (Jovay)

This example shows how to use **Chainlink CCIP** to send cross-chain messages and transfer tokens between **Ethereum Sepolia** and **Jovay Testnet**, using **Foundry**.

## Features

- **Cross-chain messaging**: send arbitrary bytes between chains
- **Cross-chain token transfers**: transfer CCIP-enabled tokens between supported chains
- **Flexible fee payment**: pay CCIP fees in **LINK** or **native gas token** (ETH)

## Network configuration

| Network | Router | LINK | Chain Selector |
|---|---|---|---|
| Ethereum Sepolia | `0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59` | `0x779877A7B0D9E8603169DdbD7836e478b4624789` | `16015286601757825753` |
| Jovay Testnet | `0x2016AA303B331bd739Fd072998e579a3052500A6` | `0xd3e461C55676B10634a5F81b747c324B85686Dd1` | `945045181441419236` |

## Prerequisites

- Git
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Testnet funds:
  - Sepolia ETH + test LINK
  - Jovay testnet gas token

## Install

From a fresh clone (recommended):

```bash
git clone --recurse-submodules <REPO_URL>
cd jovay-examples/chainlink_examples/ccip_example
```

If you already cloned the repo:

```bash
cd jovay-examples
git submodule update --init --recursive
cd chainlink_examples/ccip_example
```

## Environment

Create a local `.env` file:

```bash
cp .env.example .env
```

Export the variables into your shell (bash/zsh):

```bash
set -a
source .env
set +a
```

## Build & test

```bash
forge build
forge test --offline
```

Notes:
- `--offline` avoids network access and works around a known Foundry macOS crash related to system proxy detection.

## Contracts

- **`Sender.sol`**: sends CCIP messages (LINK fee or native fee).
- **`Receiver.sol`**: receives CCIP messages (stores last message + history).
- **`TokenTransferor.sol`**: transfers tokens cross-chain via CCIP (LINK fee or native fee).

## Scenario A: Send a message (Sepolia → Jovay)

### 1) Deploy `Receiver` on Jovay Testnet

```bash
forge script script/DeployReceiver.s.sol:DeployReceiverJovay \
  --rpc-url jovay_testnet \
  --broadcast
```

Record the deployed receiver address.

### 2) Deploy `Sender` on Ethereum Sepolia

```bash
forge script script/DeploySender.s.sol:DeploySenderSepolia \
  --rpc-url sepolia \
  --broadcast
```

Record the deployed sender address.

### 3) Fund `Sender`

- If paying fees with **LINK**, transfer LINK to the `Sender` contract (get test LINK from the Chainlink faucet).
- If paying fees with **native ETH**, transfer a small amount of Sepolia ETH to the `Sender` contract.

### 4) Send the message

```bash
export SENDER_ADDRESS=<SENDER_CONTRACT_ADDRESS>
export RECEIVER_ADDRESS=<RECEIVER_CONTRACT_ADDRESS>
export MESSAGE="Hello from Sepolia!"

# Pay fees with LINK
forge script script/SendMessage.s.sol:SendMessageToJovay \
  --rpc-url sepolia \
  --broadcast

# Or pay fees with native ETH
forge script script/SendMessage.s.sol:SendMessageToJovayPayNative \
  --rpc-url sepolia \
  --broadcast
```

### 5) Track and verify

- Track on [CCIP Explorer](https://ccip.chain.link/)
- Verify on Jovay:

```bash
cast call $RECEIVER_ADDRESS "getLastReceivedMessageDetails()" --rpc-url jovay_testnet
```

## Scenario B: Transfer tokens (Sepolia → Jovay)

If you need to register custom tokens for CCIP, use Chainlink Token Manager:
- Testnet: [Token Manager (testnet)](https://test.tokenmanager.chain.link/)
- Mainnet: [Token Manager (mainnet)](https://tokenmanager.chain.link/)

### 1) Deploy `TokenTransferor` on Sepolia

```bash
forge script script/DeployTokenTransferor.s.sol:DeployTokenTransferorSepolia \
  --rpc-url sepolia \
  --broadcast

export TOKEN_TRANSFEROR=<TOKEN_TRANSFEROR_ADDRESS>
```

### 2) Allowlist Jovay as destination

```bash
forge script script/TransferToken.s.sol:AllowlistJovay \
  --rpc-url sepolia \
  --broadcast
```

### 3) Fund and transfer

- Transfer some **LINK** to `TokenTransferor` to pay CCIP fees.
- Transfer some **CCIP-BnM** (test token) to `TokenTransferor` to be bridged.

```bash
export RECEIVER=<DESTINATION_EOA_OR_CONTRACT>
export AMOUNT=2000000000000000 # 0.002 BnM

forge script script/TransferToken.s.sol:TransferTokenToJovay \
  --rpc-url sepolia \
  --broadcast
```

## Test tokens

| Token | Ethereum Sepolia | Jovay Testnet |
|---|---|---|
| CCIP-BnM | `0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05` | `0xB45B9eb94F25683B47e5AFb0f74A05a58be86311` |

## Troubleshooting

### `InsufficientLinkBalance`

Fund the contract with more LINK, or call `estimateFee()` first to estimate the required fee.

### Message stuck at “Waiting for Finality”

This is normal. CCIP messages wait for enough confirmations on the source chain.

### Foundry panics on macOS during `forge test`

Run:

```bash
forge test --offline
```

## Links

- [Chainlink CCIP docs](https://docs.chain.link/ccip)
- [CCIP Billing](https://docs.chain.link/ccip/billing)
- [CCIP Explorer](https://ccip.chain.link/)
- [CCIP test tokens](https://docs.chain.link/ccip/test-tokens)
- [Jovay CCIP docs](https://docs.jovay.io/developer/chainlink/ccip-overview)

## License

MIT
