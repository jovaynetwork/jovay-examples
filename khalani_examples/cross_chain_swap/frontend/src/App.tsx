import { useReducer, useEffect } from 'react';
import { SwapForm } from './components/SwapForm';
import { WalletProvider, useWalletContext } from './components/WalletProvider';
import { useKhalaniAPI } from './hooks/useKhalaniAPI';
import { NETWORKS, getToken, parseTokenAmount } from './config';
import { SwapState, SwapAction } from './types';

const initialState: SwapState = {
  fromNetwork: NETWORKS.ETHEREUM,
  toNetwork: NETWORKS.JOVAY,
  fromToken: getToken('ETH', NETWORKS.ETHEREUM),
  toToken: getToken('ETH', NETWORKS.JOVAY),
  amount: '',
  quote: null,
  route: null,
  orderId: null,
  orderStatus: null,
  isFetchingQuote: false,
  isBuildingDeposit: false,
  isSubmitting: false,
  isTrackingOrder: false,
  error: null,
  fromTokenBalance: null,
  toTokenBalance: null,
  isFetchingBalance: false,
  isSwitchingNetwork: false,
};

function swapReducer(state: SwapState, action: SwapAction): SwapState {
  switch (action.type) {
    case 'SET_FROM_NETWORK':
      return { ...state, fromNetwork: action.network, fromToken: getToken(state.fromToken.key, action.network), quote: null, route: null };
    case 'SET_TO_NETWORK':
      return { ...state, toNetwork: action.network, toToken: getToken(state.toToken.key, action.network), quote: null, route: null };
    case 'SET_FROM_TOKEN':
      // Update fromToken and auto-update toToken to match key (ETH ↔ ETH, USDC ↔ USDC)
      return {
        ...state,
        fromToken: action.token,
        toToken: getToken(action.token.key, state.toNetwork),
        quote: null,
        route: null
      };
    case 'SET_TO_TOKEN':
      // Update toToken and auto-update fromToken to match key (ETH ↔ ETH, USDC ↔ USDC)
      return {
        ...state,
        fromToken: getToken(action.token.key, state.fromNetwork),
        toToken: action.token,
        quote: null,
        route: null
      };
    case 'SET_AMOUNT':
      return { ...state, amount: action.amount, quote: null, route: null };
    case 'SWITCH_NETWORKS':
      // Swap from/to networks while preserving token correspondence
      // This ensures ETH ↔ ETH and USDC ↔ USDC when swapping networks
      return {
        ...initialState,
        fromNetwork: state.toNetwork,
        toNetwork: state.fromNetwork,
        fromToken: getToken(state.fromToken.key, state.toNetwork),
        toToken: getToken(state.toToken.key, state.fromNetwork),
      };
    case 'FETCHING_QUOTE':
      return { ...state, isFetchingQuote: action.isFetching, error: null };
    case 'QUOTE_RECEIVED':
      return { ...state, quote: action.quote, route: action.route, error: null };
    case 'BUILDING_DEPOSIT':
      return { ...state, isBuildingDeposit: action.isBuilding, error: null };
    case 'SUBMITTING':
      return { ...state, isSubmitting: action.isSubmitting, error: null };
    case 'ORDER_CREATED':
      return { ...state, orderId: action.orderId, error: null };
    case 'ORDER_STATUS_UPDATED':
      return { ...state, orderStatus: action.status };
    case 'TRACKING_ORDER':
      return { ...state, isTrackingOrder: action.isTracking };
    case 'SET_ERROR':
      return { ...state, error: action.error };
    case 'RESET':
      return initialState;
    case 'SET_FROM_TOKEN_BALANCE':
      return { ...state, fromTokenBalance: action.balance };
    case 'SET_TO_TOKEN_BALANCE':
      return { ...state, toTokenBalance: action.balance };
    case 'FETCHING_BALANCE':
      return { ...state, isFetchingBalance: action.isFetching };
    case 'SWITCHING_NETWORK':
      return { ...state, isSwitchingNetwork: action.isSwitching };
    default:
      return state;
  }
}

function AppContent() {
  const [state, dispatch] = useReducer(swapReducer, initialState);
  const { address, chainId, isConnected, connect, disconnect, switchNetwork, sendTransaction } = useWalletContext();
  const { requestQuote, buildDeposit, submitDeposit, pollOrderStatus, error: apiError } = useKhalaniAPI();

  useEffect(() => {
    if (apiError) {
      dispatch({ type: 'SET_ERROR', error: apiError });
    }
  }, [apiError]);

  // Function to fetch token balance using network's RPC URL
  const fetchTokenBalance = async (token: any, network: any) => {
    if (!address) {
      return null;
    }

    dispatch({ type: 'FETCHING_BALANCE', isFetching: true });

    try {
      const rpcUrl = network.rpcUrl;

      // Native token balance (ETH) - use RPC call
      if (token.isNative) {
        const response = await fetch(rpcUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            jsonrpc: '2.0',
            method: 'eth_getBalance',
            params: [address.toLowerCase(), 'latest'],
            id: 1,
          }),
        });

        const data = await response.json();

        // Check for RPC error
        if (data.error) {
          console.error(`RPC error on ${network.name}:`, data.error);
          dispatch({ type: 'FETCHING_BALANCE', isFetching: false });
          return null;
        }

        dispatch({ type: 'FETCHING_BALANCE', isFetching: false });
        return data.result || '0x0';
      } else {
        // ERC-20 token balance (USDC) - use RPC call
        // balanceOf selector (4 bytes) + owner address (32 bytes, padded)
        const addressLower = address.toLowerCase().startsWith('0x')
          ? address.toLowerCase().slice(2)
          : address.toLowerCase();
        const balanceOfData = `0x70a08231${addressLower.padStart(64, '0')}`;
        const response = await fetch(rpcUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            jsonrpc: '2.0',
            method: 'eth_call',
            params: [{ to: token.address, data: balanceOfData }, 'latest'],
            id: 1,
          }),
        });

        const data = await response.json();

        // Check for RPC error
        if (data.error) {
          console.error(`RPC error on ${network.name}:`, data.error);
          dispatch({ type: 'FETCHING_BALANCE', isFetching: false });
          return null;
        }

        dispatch({ type: 'FETCHING_BALANCE', isFetching: false });
        return data.result || '0x0';
      }
    } catch (err) {
      dispatch({ type: 'FETCHING_BALANCE', isFetching: false });
      console.error(`Failed to fetch balance on ${network.name}:`, err);
      return null;
    }
  };

  // Fetch initial balances when wallet connects
  useEffect(() => {
    if (isConnected && address) {
      fetchTokenBalance(state.fromToken, state.fromNetwork).then(balance => {
        dispatch({ type: 'SET_FROM_TOKEN_BALANCE', balance });
      });
      fetchTokenBalance(state.toToken, state.toNetwork).then(balance => {
        dispatch({ type: 'SET_TO_TOKEN_BALANCE', balance });
      });
    }
  }, [isConnected, address]);

  // Update from token balance when fromToken changes
  useEffect(() => {
    if (isConnected && address) {
      fetchTokenBalance(state.fromToken, state.fromNetwork).then(balance => {
        dispatch({ type: 'SET_FROM_TOKEN_BALANCE', balance });
      });
    }
  }, [state.fromToken, state.fromNetwork, isConnected, address]);

  // Update to token balance when toToken changes
  useEffect(() => {
    if (isConnected && address) {
      fetchTokenBalance(state.toToken, state.toNetwork).then(balance => {
        dispatch({ type: 'SET_TO_TOKEN_BALANCE', balance });
      });
    }
  }, [state.toToken, state.toNetwork, isConnected, address]);

  // Update balances when chainId changes
  useEffect(() => {
    if (isConnected && address && chainId) {
      const network = Object.values(NETWORKS).find(n => n.chainId === chainId);
      if (network) {
        // Check if we need to update balances
        const shouldUpdateFrom = state.fromNetwork.chainId === chainId;
        const shouldUpdateTo = state.toNetwork.chainId === chainId;

        if (shouldUpdateFrom) {
          fetchTokenBalance(state.fromToken, network).then(balance => {
            dispatch({ type: 'SET_FROM_TOKEN_BALANCE', balance });
          });
        }

        if (shouldUpdateTo) {
          fetchTokenBalance(state.toToken, network).then(balance => {
            dispatch({ type: 'SET_TO_TOKEN_BALANCE', balance });
          });
        }
      }
    }
  }, [chainId, isConnected, address]);

  const handleSwitchNetwork = async () => {
    dispatch({ type: 'SWITCHING_NETWORK', isSwitching: true });
    const result = await switchNetwork(
      state.fromNetwork.chainId,
      state.fromNetwork.rpcUrl,
      state.fromNetwork.explorer
    );
    dispatch({ type: 'SWITCHING_NETWORK', isSwitching: false });
    if (!result.success) {
      dispatch({ type: 'SET_ERROR', error: result.error || 'Failed to switch network' });
    }
  };

  const handleGetQuote = async () => {
    if (!address) {
      alert('Please connect your wallet first');
      return;
    }

    if (!state.amount || parseFloat(state.amount) <= 0) {
      dispatch({ type: 'SET_ERROR', error: 'Please enter a valid amount' });
      return;
    }

    dispatch({ type: 'FETCHING_QUOTE', isFetching: true });

    const result = await requestQuote({
      fromAddress: address,
      tradeType: 'EXACT_INPUT',
      fromChainId: state.fromNetwork.chainId,
      fromToken: state.fromToken.isNative ? '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE' : state.fromToken.address,
      toChainId: state.toNetwork.chainId,
      toToken: state.toToken.isNative ? '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE' : state.toToken.address,
      amount: parseTokenAmount(state.amount, state.fromToken.decimals),
    });

    if (result.success && result.data && result.data.routes.length > 0) {
      dispatch({ type: 'QUOTE_RECEIVED', quote: result.data, route: result.data.routes[0] });
    } else {
      dispatch({ type: 'SET_ERROR', error: result.error || 'Failed to get quote' });
    }
  };

  const handleConfirmTransaction = async () => {
    if (!address || !state.quote || !state.route) {
      return;
    }

    // Check if user is on correct network
    if (chainId !== state.fromNetwork.chainId) {
      const switchResult = await switchNetwork(
        state.fromNetwork.chainId,
        state.fromNetwork.rpcUrl,
        state.fromNetwork.explorer
      );
      if (!switchResult.success) {
        dispatch({ type: 'SET_ERROR', error: switchResult.error || 'Failed to switch network' });
        return;
      }
    }

    dispatch({ type: 'BUILDING_DEPOSIT', isBuilding: true });

    // Build deposit plan - ensure address is lowercase
    const buildResult = await buildDeposit({
      from: address?.toLowerCase(),
      quoteId: state.quote.quoteId,
      routeId: state.route.routeId,
    });

    if (!buildResult.success || !buildResult.data) {
      dispatch({ type: 'SET_ERROR', error: buildResult.error || 'Failed to build deposit' });
      dispatch({ type: 'BUILDING_DEPOSIT', isBuilding: false });
      return;
    }

    const depositPlan = buildResult.data;
    console.log('Deposit plan:', depositPlan);
    const actions = depositPlan.approvals || [];
    console.log('Actions:', actions);

    let depositTxHash: string | null = null;

    try {
      // Get ethereum object for special wallet methods
      const ethereum = (window as any).ethereum;

      // Execute wallet actions
      for (const action of actions) {
        const req = action.request;

        if (!req?.method) {
          throw new Error('Invalid deposit plan action');
        }

        // Handle special wallet methods (switch/add network)
        if (req.method === 'wallet_switchEthereumChain' || req.method === 'wallet_addEthereumChain') {
          if (!ethereum) {
            throw new Error('Wallet not found');
          }
          await ethereum.request({
            method: req.method,
            params: req.params,
          });
          continue;
        }

        // Handle eth_sendTransaction
        if (req.method === 'eth_sendTransaction') {
          const params = req.params as any[];
          const txData = params?.[0];

          if (!txData?.to) {
            console.error('Missing to address in transaction:', req);
            throw new Error('Invalid transaction: missing recipient address');
          }

          console.log('Sending transaction:', {
            from: txData.from,
            to: txData.to,
            value: txData.value,
            data: txData.data?.slice(0, 100) + '...'
          });

          const result = await sendTransaction({
            from: txData.from,
            to: txData.to,
            value: txData.value,
            data: txData.data,
          });

          if (!result.success) {
            throw new Error(result.error || 'Transaction failed');
          }

          // Capture deposit tx hash
          if (action.deposit) {
            depositTxHash = result.txHash || null;
          }
        }
      }

      if (!depositTxHash) {
        throw new Error('No deposit transaction hash found');
      }

      // Submit deposit
      dispatch({ type: 'SUBMITTING', isSubmitting: true });

      const submitResult = await submitDeposit({
        txHash: depositTxHash,
        quoteId: state.quote.quoteId,
        routeId: state.route.routeId,
      });

      if (submitResult.success && submitResult.data) {
        dispatch({ type: 'ORDER_CREATED', orderId: submitResult.data.orderId });

        // Start polling order status
        dispatch({ type: 'TRACKING_ORDER', isTracking: true });
        await pollOrderStatus(address, submitResult.data.orderId, (order) => {
          dispatch({ type: 'ORDER_STATUS_UPDATED', status: order.status });
        });
        dispatch({ type: 'TRACKING_ORDER', isTracking: false });
      } else {
        dispatch({ type: 'SET_ERROR', error: submitResult.error || 'Failed to submit deposit' });
      }
    } catch (err) {
      dispatch({ type: 'SET_ERROR', error: err instanceof Error ? err.message : 'Transaction failed' });
    } finally {
      dispatch({ type: 'BUILDING_DEPOSIT', isBuilding: false });
      dispatch({ type: 'SUBMITTING', isSubmitting: false });
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-12 px-4">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">
            Khalani Cross-Chain Swap Example
          </h1>
          {isConnected ? (
            <div className="flex items-center space-x-4">
              <div className="text-sm text-gray-700">
                <span className="font-medium">{address?.slice(0, 6)}...{address?.slice(-4)}</span>
              </div>
              <button
                onClick={disconnect}
                className="px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-lg hover:bg-red-700 transition-colors"
              >
                Disconnect
              </button>
            </div>
          ) : (
            <button
              onClick={async () => {
                const result = await connect();
                if (!result.success) {
                  alert(result.error || 'Failed to connect wallet');
                }
              }}
              disabled={false}
              className="px-6 py-2 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 transition-colors"
            >
              Connect Wallet
            </button>
          )}
        </div>

        {/* Main Content */}
        <SwapForm
          state={state}
          dispatch={dispatch}
          onGetQuote={handleGetQuote}
          onConfirmTransaction={handleConfirmTransaction}
          onSwitchNetwork={handleSwitchNetwork}
          isSwitchingNetwork={state.isSwitchingNetwork}
          isConnected={isConnected}
          chainId={chainId}
          onReset={() => dispatch({ type: 'RESET' })}
        />

        {/* Footer */}
        <div className="mt-12 text-center text-sm text-gray-600">
          <p>
            Powered by <a href="https://khalani.network" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800">Khalani Intent Markets</a>
          </p>
          <p className="mt-2">
            Support: <a href="https://docs.khalani.io" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800">Documentation</a> |{' '}
            <a href="https://discord.gg/khalani" target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:text-blue-800">Discord</a>
          </p>
        </div>
      </div>
    </div>
  );
}

function App() {
  return (
    <WalletProvider>
      <AppContent />
    </WalletProvider>
  );
}

export default App;
