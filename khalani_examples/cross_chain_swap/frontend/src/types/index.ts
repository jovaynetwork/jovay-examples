// Network types
export interface Network {
  chainId: number;
  name: string;
  rpcUrl: string;
  explorer: string;
  nativeCurrency: {
    name: string;
    symbol: string;
    decimals: number;
  };
  usdcAddress: string;
}

// Token types
export interface Token {
  key: string; // Internal key for token correspondence (e.g., "ETH", "USDC") - constant across networks
  symbol: string; // Display symbol (e.g., "USDC" on Ethereum, "USDC.e" on Jovay)
  name: string;
  address: string;
  decimals: number;
  isNative: boolean;
}

// Khalani API types
export interface QuoteRequest {
  fromAddress: string;
  tradeType: 'EXACT_INPUT' | 'EXACT_OUTPUT';
  fromChainId: number;
  fromToken: string;
  toChainId: number;
  toToken: string;
  amount: string;
}

export interface QuoteResponse {
  quoteId: string;
  routes: Route[];
}

export interface Route {
  routeId: string;
  type: string;
  exactOutMethod?: string;
  quote: {
    amountIn: string;
    amountOut: string;
    expectedDurationSeconds: number;
    validBefore: number;
  };
}

export interface DepositBuildRequest {
  from: string;
  quoteId: string;
  routeId: string;
}

export interface DepositPlan {
  kind: 'CONTRACT_CALL';
  approvals?: WalletAction[];
}

export interface WalletAction {
  type: 'eip1193_request';
  request: {
    method: string;
    params?: unknown[];
  };
  deposit?: boolean;
  waitForReceipt?: boolean;
}

export interface SubmitDepositRequest {
  txHash: string;
  quoteId: string;
  routeId: string;
}

export interface SubmitResponse {
  orderId: string;
}

export type OrderStatus = 'created' | 'deposited' | 'published' | 'filled' | 'refunded' | 'failed';

export interface Order {
  id: string;
  status: OrderStatus;
  fromChainId: number;
  toChainId: number;
  fromToken: string;
  toToken: string;
  srcAmount: string;
  destAmount: string;
  fromDecimals: number;
  toDecimals: number;
  depositTxHash: string | null;
  createdAt: string;
  updatedAt: string;
  quoteId: string;
  routeId: string;
}

export interface OrdersResponse {
  data: Order[];
  cursor?: number;
}

// App state types
export interface SwapState {
  fromNetwork: Network;
  toNetwork: Network;
  fromToken: Token;
  toToken: Token;
  amount: string;
  quote: QuoteResponse | null;
  route: Route | null;
  orderId: string | null;
  orderStatus: OrderStatus | null;
  isFetchingQuote: boolean;
  isBuildingDeposit: boolean;
  isSubmitting: boolean;
  isTrackingOrder: boolean;
  error: string | null;
  fromTokenBalance: string | null;
  toTokenBalance: string | null;
  isFetchingBalance: boolean;
  isSwitchingNetwork: boolean;
}

export type SwapAction =
  | { type: 'SET_FROM_NETWORK'; network: Network }
  | { type: 'SET_TO_NETWORK'; network: Network }
  | { type: 'SET_FROM_TOKEN'; token: Token }
  | { type: 'SET_TO_TOKEN'; token: Token }
  | { type: 'SET_AMOUNT'; amount: string }
  | { type: 'SWITCH_NETWORKS' }
  | { type: 'FETCHING_QUOTE'; isFetching: boolean }
  | { type: 'QUOTE_RECEIVED'; quote: QuoteResponse; route: Route }
  | { type: 'BUILDING_DEPOSIT'; isBuilding: boolean }
  | { type: 'SUBMITTING'; isSubmitting: boolean }
  | { type: 'ORDER_CREATED'; orderId: string }
  | { type: 'ORDER_STATUS_UPDATED'; status: OrderStatus }
  | { type: 'TRACKING_ORDER'; isTracking: boolean }
  | { type: 'RESET' }
  | { type: 'SET_ERROR'; error: string | null }
  | { type: 'SET_FROM_TOKEN_BALANCE'; balance: string | null }
  | { type: 'SET_TO_TOKEN_BALANCE'; balance: string | null }
  | { type: 'FETCHING_BALANCE'; isFetching: boolean }
  | { type: 'SWITCHING_NETWORK'; isSwitching: boolean };
