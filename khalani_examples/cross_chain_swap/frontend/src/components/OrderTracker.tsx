import { Order, OrderStatus } from '../types';
import { formatTokenAmount } from '../config';

interface OrderTrackerProps {
  order: Order | null;
  isTracking: boolean;
  onClose: () => void;
}

const CHAIN_EXPLORERS: Record<number, string> = {
  1: 'https://etherscan.io',
  5734951: 'https://explorer.jovay.io',
};

const getExplorerUrl = (chainId: number, txHash: string): string => {
  const explorer = CHAIN_EXPLORERS[chainId];
  if (!explorer) return '#';
  return `${explorer}/tx/${txHash}`;
};

const statusConfig: Record<OrderStatus, { label: string; color: string; icon: string }> = {
  created: { label: 'Created', color: 'bg-blue-500', icon: '📝' },
  deposited: { label: 'Deposited', color: 'bg-yellow-500', icon: '💰' },
  published: { label: 'Published', color: 'bg-purple-500', icon: '📢' },
  filled: { label: 'Filled', color: 'bg-green-500', icon: '✅' },
  refunded: { label: 'Refunded', color: 'bg-red-500', icon: '↩️' },
  failed: { label: 'Failed', color: 'bg-red-600', icon: '❌' },
};

export const OrderTracker = ({ order, isTracking, onClose }: OrderTrackerProps) => {
  if (!order) {
    return null;
  }

  const statusInfo = statusConfig[order.status];
  const statusOrder: OrderStatus[] = ['created', 'deposited', 'published', 'filled'];

  const currentIndex = statusOrder.indexOf(order.status);
  const isTerminal = ['filled', 'refunded', 'failed'].includes(order.status);

  return (
    <div className="w-full max-w-2xl mx-auto mt-8 p-6 bg-white border border-gray-200 rounded-lg shadow-md">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xl font-bold text-gray-900">Order Tracking</h3>
        <button
          onClick={onClose}
          className="p-1 text-gray-500 hover:text-gray-700 transition-colors"
          title="Close and return"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <div className="space-y-4">
        <div className="flex items-center justify-between py-3 border-b border-gray-200">
          <span className="text-sm font-medium text-gray-700">Order ID</span>
          <span className="text-sm font-mono text-gray-900">{order.id.slice(0, 8)}...</span>
        </div>

        <div className="flex items-center justify-between py-3 border-b border-gray-200">
          <span className="text-sm font-medium text-gray-700">Status</span>
          <div className="flex items-center space-x-2">
            <span className="text-2xl">{statusInfo.icon}</span>
            <span className={`px-3 py-1 rounded-full text-sm font-semibold text-white ${statusInfo.color}`}>
              {statusInfo.label}
            </span>
          </div>
        </div>

        {isTracking && (
          <div className="flex items-center justify-center py-3">
            <div className="flex items-center space-x-2 text-blue-600">
              <svg
                className="animate-spin h-5 w-5"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                ></circle>
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                ></path>
              </svg>
              <span className="text-sm font-medium">Tracking order status...</span>
            </div>
          </div>
        )}

        <div className="space-y-2 py-3">
          <h4 className="text-sm font-semibold text-gray-700">Progress</h4>
          <div className="flex items-center justify-between">
            {statusOrder.map((status, index) => {
              const isCompleted = index <= currentIndex;
              const isCurrent = index === currentIndex;
              const config = statusConfig[status];

              return (
                <div key={status} className="flex flex-col items-center flex-1">
                  <div
                    className={`w-10 h-10 rounded-full flex items-center justify-center text-lg ${
                      isCompleted ? config.color : 'bg-gray-300'
                    }`}
                  >
                    {config.icon}
                  </div>
                  <span
                    className={`text-xs mt-2 text-center ${
                      isCurrent ? 'font-bold text-gray-900' : 'text-gray-600'
                    }`}
                  >
                    {config.label}
                  </span>
                </div>
              );
            })}
          </div>
        </div>

        <div className="flex items-center justify-between py-3 border-b border-gray-200">
          <span className="text-sm font-medium text-gray-700">Source Amount</span>
          <span className="text-sm font-mono text-gray-900">
            {formatTokenAmount(order.srcAmount, order.fromDecimals)}
          </span>
        </div>

        <div className="flex items-center justify-between py-3 border-b border-gray-200">
          <span className="text-sm font-medium text-gray-700">Destination Amount</span>
          <span className="text-sm font-mono text-gray-900">
            {formatTokenAmount(order.destAmount, order.toDecimals)}
          </span>
        </div>

        {order.depositTxHash && (
          <div className="flex items-center justify-between py-3 border-b border-gray-200">
            <span className="text-sm font-medium text-gray-700">Deposit Tx</span>
            <a
              href={getExplorerUrl(order.fromChainId, order.depositTxHash)}
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm text-blue-600 hover:text-blue-800 underline"
            >
              {order.depositTxHash.slice(0, 10)}...
            </a>
          </div>
        )}

        <div className="flex items-center justify-between py-3 border-b border-gray-200">
          <span className="text-sm font-medium text-gray-700">Created At</span>
          <span className="text-sm text-gray-900">
            {new Date(order.createdAt).toLocaleString()}
          </span>
        </div>

        {isTerminal && (
          <div className="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <p className="text-sm text-blue-800">
              {order.status === 'filled'
                ? 'Your cross-chain swap has been completed successfully!'
                : order.status === 'refunded'
                ? 'Your transaction has been refunded.'
                : 'Your transaction failed. Please try again.'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
};
