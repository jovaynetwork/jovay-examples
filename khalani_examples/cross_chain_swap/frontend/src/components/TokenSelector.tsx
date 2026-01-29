import { Token } from '../types';

interface TokenSelectorProps {
  tokens: Token[];
  selectedToken: Token;
  onSelect: (token: Token) => void;
  label: string;
  disabled?: boolean;
  balance?: string | null;
  decimals?: number;
  isLoading?: boolean;
}

export const TokenSelector = ({
  tokens,
  selectedToken,
  onSelect,
  label,
  disabled,
  balance,
  decimals,
  isLoading,
}: TokenSelectorProps) => {
  const formatBalance = (balanceStr: string | null, tokenDecimals: number) => {
    if (!balanceStr || balanceStr === 'Loading...') return balanceStr;
    const value = BigInt(balanceStr);
    const divisor = BigInt(10 ** tokenDecimals);
    const integerPart = value / divisor;
    const fractionalPart = value % divisor;

    if (fractionalPart === BigInt(0)) {
      return integerPart.toString();
    }

    const fractionalStr = fractionalPart
      .toString()
      .padStart(tokenDecimals, '0')
      .replace(/0+$/, '');

    return `${integerPart}.${fractionalStr}`;
  };

  return (
    <div className="flex flex-col space-y-2">
      <label className="text-sm font-medium text-gray-700">{label}</label>
      <div className="relative">
        <select
          value={selectedToken.symbol}
          onChange={(e) => {
            const token = tokens.find((t) => t.symbol === e.target.value);
            if (token) {
              onSelect(token);
            }
          }}
          disabled={disabled}
          className="w-full px-4 py-3 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed appearance-none cursor-pointer"
        >
          {tokens.map((token) => (
            <option key={token.symbol} value={token.symbol}>
              {token.symbol} - {token.name}
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
      {balance !== undefined && balance !== null && !isLoading && decimals !== undefined && (
        <p className="text-xs text-gray-500">
          Balance: {formatBalance(balance, decimals)} {selectedToken.symbol}
        </p>
      )}
      {isLoading && (
        <p className="text-xs text-gray-500">
          Loading...
        </p>
      )}
      {!isLoading && balance === null && (
        <p className="text-xs text-gray-500">
          Balance: Not available
        </p>
      )}
      <p className="text-xs text-gray-500">
        {selectedToken.isNative ? 'Native token' : 'ERC-20'}
      </p>
    </div>
  );
};
