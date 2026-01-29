import { Network, Token } from './types';

// Network configurations
export const NETWORKS: Record<string, Network> = {
  ETHEREUM: {
    chainId: 1,
    name: 'Ethereum',
    rpcUrl: 'https://eth.llamarpc.com',
    explorer: 'https://etherscan.io',
    nativeCurrency: {
      name: 'Ethereum',
      symbol: 'ETH',
      decimals: 18,
    },
    usdcAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
  },
  JOVAY: {
    chainId: 5734951,
    name: 'Jovay',
    rpcUrl: 'https://rpc.jovay.io',
    explorer: 'https://explorer.jovay.io',
    nativeCurrency: {
      name: 'Jovay',
      symbol: 'ETH',
      decimals: 18,
    },
    // Note: USDC address on Jovay needs to be confirmed
    // Using a placeholder - update with actual address
    usdcAddress: '0x...', // TODO: Confirm Jovay USDC address
  },
};

// Token configurations
export const TOKENS: Record<string, (network: Network) => Token> = {
  ETH: (network: Network): Token => ({
    symbol: 'ETH',
    name: network.name,
    address: '0x0000000000000000000000000000000000000000',
    decimals: 18,
    isNative: true,
  }),
  USDC: (network: Network): Token => ({
    symbol: 'USDC',
    name: 'USD Coin',
    address: network.usdcAddress,
    decimals: 6,
    isNative: false,
  }),
};

// Khalani API configuration
export const KHALANI_API_BASE_URL = 'https://api.hyperstream.dev';

// Helper function to get token by symbol for a network
export const getToken = (symbol: string, network: Network): Token => {
  const tokenFactory = TOKENS[symbol.toUpperCase()];
  if (!tokenFactory) {
    throw new Error(`Unknown token: ${symbol}`);
  }
  return tokenFactory(network);
};

// Format token amount with proper decimals
export const formatTokenAmount = (amount: string, decimals: number): string => {
  const value = BigInt(amount);
  const divisor = BigInt(10 ** decimals);
  const integerPart = value / divisor;
  const fractionalPart = value % divisor;

  if (fractionalPart === BigInt(0)) {
    return integerPart.toString();
  }

  const fractionalStr = fractionalPart
    .toString()
    .padStart(decimals, '0')
    .replace(/0+$/, '');

  return `${integerPart}.${fractionalStr}`;
};

// Parse token amount input to smallest unit
export const parseTokenAmount = (amount: string, decimals: number): string => {
  const parts = amount.split('.');
  let result = parts[0].replace(/\D/g, '') || '0';
  result = result.padStart(1, '0');

  if (parts.length > 1) {
    let fractional = parts[1].replace(/\D/g, '').slice(0, decimals);
    fractional = fractional.padEnd(decimals, '0');
    result += fractional;
  } else {
    result = result + '0'.repeat(decimals);
  }

  return result;
};

// Format address for display
export const formatAddress = (address: string, length = 6): string => {
  if (!address) return '';
  return `${address.slice(0, 2 + length)}...${address.slice(-length)}`;
};

// Get chain info for wagmi
export const getChainInfo = (chainId: number) => {
  const network = Object.values(NETWORKS).find(n => n.chainId === chainId);
  if (!network) {
    throw new Error(`Unknown chain ID: ${chainId}`);
  }
  return {
    id: network.chainId,
    name: network.name,
    nativeCurrency: network.nativeCurrency,
    rpcUrls: {
      default: { http: [network.rpcUrl] },
      public: { http: [network.rpcUrl] },
    },
    blockExplorers: {
      default: { name: 'Block Explorer', url: network.explorer },
    },
  };
};
