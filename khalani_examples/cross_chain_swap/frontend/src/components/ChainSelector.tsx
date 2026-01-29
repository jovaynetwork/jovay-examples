import { Network } from '../types';

interface ChainSelectorProps {
  networks: Network[];
  selectedNetwork: Network;
  onSelect: (network: Network) => void;
  label: string;
  disabled?: boolean;
}

export const ChainSelector = ({ networks, selectedNetwork, onSelect, label, disabled }: ChainSelectorProps) => {
  return (
    <div className="flex flex-col space-y-2">
      <label className="text-sm font-medium text-gray-700">{label}</label>
      <div className="relative">
        <select
          value={selectedNetwork.chainId}
          onChange={(e) => {
            const network = networks.find((n) => n.chainId === Number(e.target.value));
            if (network) {
              onSelect(network);
            }
          }}
          disabled={disabled}
          className="w-full px-4 py-3 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed appearance-none cursor-pointer"
        >
          {networks.map((network) => (
            <option key={network.chainId} value={network.chainId}>
              {network.name}
            </option>
          ))}
        </select>
        <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-4">
          <svg
            className="w-4 h-4 text-gray-500"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M19 9l-7 7-7-7"
            />
          </svg>
        </div>
      </div>
      <p className="text-xs text-gray-500">
        Chain ID: {selectedNetwork.chainId}
      </p>
    </div>
  );
};
