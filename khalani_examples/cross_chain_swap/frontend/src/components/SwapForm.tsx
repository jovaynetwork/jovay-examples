import { useState, useEffect } from 'react';
import { SwapState, SwapAction } from '../types';
import { NETWORKS, getToken, formatTokenAmount } from '../config';
import { ChainSelector } from './ChainSelector';
import { TokenSelector } from './TokenSelector';
import { OrderTracker } from './OrderTracker';

interface SwapFormProps {
  state: SwapState;
  dispatch: React.Dispatch<SwapAction>;
  onGetQuote: () => Promise<void>;
  onConfirmTransaction: () => Promise<void>;
  onSwitchNetwork: () => Promise<void>;
  isSwitchingNetwork: boolean;
  isConnected: boolean;
  chainId: number | null;
  onReset: () => void;
}

export const SwapForm = ({
  state,
  dispatch,
  onGetQuote,
  onConfirmTransaction,
  onSwitchNetwork,
  isSwitchingNetwork,
  isConnected,
  chainId,
  onReset,
}: SwapFormProps) => {
  const [localAmount, setLocalAmount] = useState('');

  const networks = Object.values(NETWORKS);
  const fromTokens = [getToken('ETH', state.fromNetwork), getToken('USDC', state.fromNetwork)];
  const toTokens = [getToken('ETH', state.toNetwork), getToken('USDC', state.toNetwork)];

  // Sync local amount with state
  useEffect(() => {
    if (state.amount !== localAmount) {
      setLocalAmount(state.amount);
    }
  }, [state.amount]);

  const handleAmountChange = (value: string) => {
    // Only allow numbers and one decimal point
    const sanitized = value.replace(/[^\d.]/g, '').replace(/(\..*)\./g, '$1');
    setLocalAmount(sanitized);
    dispatch({ type: 'SET_AMOUNT', amount: sanitized });
  };

  const handleGetQuote = async () => {
    if (!localAmount || parseFloat(localAmount) <= 0) {
      alert('Please enter a valid amount');
      return;
    }
    await onGetQuote();
  };

  const canGetQuote = !!localAmount && parseFloat(localAmount) > 0 && !state.isFetchingQuote;

  const canConfirm = !!state.quote && !!state.route && !state.isBuildingDeposit && !state.isSubmitting;

  return (
    <div className="w-full max-w-4xl mx-auto p-6 bg-white border border-gray-200 rounded-lg shadow-lg">
      <h2 className="text-2xl font-bold text-gray-900 mb-6 text-center">
        Cross-Chain Swap Example with Khalani
      </h2>

      {!state.orderId ? (
        <>
          {/* Network Mismatch Warning */}
          {isConnected && chainId && chainId !== state.fromNetwork.chainId && (
            <div className="mb-4 p-4 bg-amber-50 border border-amber-200 rounded-lg flex items-center justify-between">
              <div className="flex items-center gap-3">
                <svg className="w-5 h-5 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
                <div>
                  <p className="text-sm font-medium text-amber-800">
                    Your wallet is connected to a different network
                  </p>
                  <p className="text-xs text-amber-600">
                    Please switch to <span className="font-semibold">{state.fromNetwork.name}</span> to proceed
                  </p>
                </div>
              </div>
              <button
                onClick={onSwitchNetwork}
                disabled={isSwitchingNetwork}
                className="px-4 py-2 bg-amber-600 text-white text-sm font-medium rounded-lg hover:bg-amber-700 disabled:opacity-50 transition-colors"
              >
                {isSwitchingNetwork ? 'Switching...' : 'Switch Network'}
              </button>
            </div>
          )}

          <div className="grid grid-cols-2 md:grid-cols-[1fr,auto,1fr] gap-2 md:gap-6 mb-6 items-center">
            <ChainSelector
              networks={networks}
              selectedNetwork={state.fromNetwork}
              onSelect={(network) => dispatch({ type: 'SET_FROM_NETWORK', network })}
              label="From Network"
              disabled={state.isFetchingQuote || state.isBuildingDeposit}
            />

            {/* Swap Button */}
            <button
              onClick={() => dispatch({ type: 'SWITCH_NETWORKS' })}
              disabled={state.isFetchingQuote || state.isBuildingDeposit}
              className="p-2 rounded-full bg-gray-100 hover:bg-gray-200 disabled:opacity-50 transition-colors mx-auto"
              title="Switch networks"
            >
              <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
              </svg>
            </button>

            <ChainSelector
              networks={networks}
              selectedNetwork={state.toNetwork}
              onSelect={(network) => dispatch({ type: 'SET_TO_NETWORK', network })}
              label="To Network"
              disabled={state.isFetchingQuote || state.isBuildingDeposit}
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <TokenSelector
              tokens={fromTokens}
              selectedToken={state.fromToken}
              onSelect={(token) => dispatch({ type: 'SET_FROM_TOKEN', token })}
              label="From Token"
              disabled={state.isFetchingQuote || state.isBuildingDeposit}
              balance={state.fromTokenBalance}
              decimals={state.fromToken.decimals}
              isLoading={state.isFetchingBalance}
              explorerUrl={state.fromNetwork.explorer}
            />

            <TokenSelector
              tokens={toTokens}
              selectedToken={state.toToken}
              onSelect={(token) => dispatch({ type: 'SET_TO_TOKEN', token })}
              label="To Token"
              disabled={state.isFetchingQuote || state.isBuildingDeposit}
              balance={state.toTokenBalance}
              decimals={state.toToken.decimals}
              isLoading={state.isFetchingBalance}
              explorerUrl={state.toNetwork.explorer}
            />
          </div>

          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">Amount</label>
            <div className="relative">
              <input
                type="text"
                value={localAmount}
                onChange={(e) => handleAmountChange(e.target.value)}
                placeholder="0.0"
                disabled={state.isFetchingQuote || state.isBuildingDeposit}
                className="w-full px-4 py-3 pr-16 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed text-lg"
              />
              <span className="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-600 font-medium">
                {state.fromToken.symbol}
              </span>
            </div>
          </div>

          <button
            onClick={handleGetQuote}
            disabled={!canGetQuote}
            className="w-full py-3 px-6 bg-blue-600 text-white font-semibold rounded-lg hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {state.isFetchingQuote ? 'Getting Quote...' : 'Get Quote'}
          </button>

          {state.quote && state.route && (
            <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
              <h3 className="text-lg font-semibold text-blue-900 mb-3">Quote Details</h3>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-sm text-blue-700">Expected Output:</span>
                  <span className="text-sm font-medium text-blue-900">
                    {formatTokenAmount(state.route.quote.amountOut, state.toToken.decimals)} {state.toToken.symbol}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-blue-700">Est. Duration:</span>
                  <span className="text-sm font-medium text-blue-900">
                    ~{state.route.quote.expectedDurationSeconds}s
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-sm text-blue-700">Valid Until:</span>
                  <span className="text-sm font-medium text-blue-900">
                    {new Date(state.route.quote.validBefore * 1000).toLocaleString()}
                  </span>
                </div>
              </div>
            </div>
          )}

          {state.quote && state.route && (
            <button
              onClick={onConfirmTransaction}
              disabled={!canConfirm}
              className="w-full mt-4 py-3 px-6 bg-green-600 text-white font-semibold rounded-lg hover:bg-green-700 focus:ring-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {state.isBuildingDeposit ? 'Preparing Transaction...' :
               state.isSubmitting ? 'Submitting...' :
               'Confirm Transaction'}
            </button>
          )}

          {state.error && (
            <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg">
              <p className="text-sm text-red-800">{state.error}</p>
            </div>
          )}
        </>
      ) : (
        <OrderTracker
          order={{
            id: state.orderId!,
            status: state.orderStatus || 'created',
            fromChainId: state.fromNetwork.chainId,
            toChainId: state.toNetwork.chainId,
            fromToken: state.fromToken.address,
            toToken: state.toToken.address,
            srcAmount: state.quote?.routes[0]?.quote.amountIn || '0',
            destAmount: state.quote?.routes[0]?.quote.amountOut || '0',
            fromDecimals: state.fromToken.decimals,
            toDecimals: state.toToken.decimals,
            depositTxHash: null,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
            quoteId: state.quote!.quoteId,
            routeId: state.route!.routeId,
          }}
          isTracking={state.isTrackingOrder}
          onClose={onReset}
        />
      )}

      <div className="mt-6 p-4 bg-gray-50 border border-gray-200 rounded-lg">
        <h3 className="text-sm font-semibold text-gray-700 mb-2">About Khalani Intent Markets</h3>
        <p className="text-xs text-gray-600 mb-2">
          Khalani uses an intent-based architecture where solvers compete to fulfill your cross-chain request.
          This ensures:
        </p>
        <ul className="text-xs text-gray-600 space-y-1 list-disc list-inside">
          <li>Competitive rates from multiple solvers</li>
          <li>Atomic execution (success or full refund)</li>
          <li>Automatic optimization as solvers improve</li>
        </ul>
      </div>

      <div className="mt-4 p-4 bg-gray-50 border border-gray-200 rounded-lg">
        <h3 className="text-sm font-semibold text-gray-700 mb-3">Token Information</h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-xs font-medium text-gray-600 mb-1">From: {state.fromNetwork.name}</p>
            <div className="space-y-1">
              <p className="text-xs text-gray-500">
                <span className="font-medium">{state.fromToken.symbol}</span>: {state.fromToken.name}
                {state.fromToken.symbol === 'USDC' && state.fromNetwork.chainId === 5734951 && (
                  <span className="text-gray-400"> (bridged USDC)</span>
                )}
              </p>
              <p className="text-xs text-gray-500">
                Address:{' '}
                {state.fromToken.isNative ? (
                  <span className="text-gray-400">Native Token</span>
                ) : (
                  <a
                    href={`${state.fromNetwork.explorer}/address/${state.fromToken.address}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:text-blue-800 underline"
                  >
                    {state.fromToken.address.slice(0, 6)}...{state.fromToken.address.slice(-4)}
                  </a>
                )}
              </p>
            </div>
          </div>
          <div>
            <p className="text-xs font-medium text-gray-600 mb-1">To: {state.toNetwork.name}</p>
            <div className="space-y-1">
              <p className="text-xs text-gray-500">
                <span className="font-medium">{state.toToken.symbol}</span>: {state.toToken.name}
                {state.toToken.symbol === 'USDC' && state.toNetwork.chainId === 5734951 && (
                  <span className="text-gray-400"> (bridged USDC)</span>
                )}
              </p>
              <p className="text-xs text-gray-500">
                Address:{' '}
                {state.toToken.isNative ? (
                  <span className="text-gray-400">Native Token</span>
                ) : (
                  <a
                    href={`${state.toNetwork.explorer}/address/${state.toToken.address}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-600 hover:text-blue-800 underline"
                  >
                    {state.toToken.address.slice(0, 6)}...{state.toToken.address.slice(-4)}
                  </a>
                )}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
