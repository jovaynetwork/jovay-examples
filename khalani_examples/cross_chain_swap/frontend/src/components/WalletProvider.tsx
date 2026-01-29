import { createContext, useContext, ReactNode } from 'react';
import { useWallet } from '../hooks/useWallet';

interface WalletContextType {
  address: string | null;
  chainId: number | null;
  isConnected: boolean;
  isConnecting: boolean;
  connect: () => Promise<{ success: boolean; address?: string; error?: string }>;
  disconnect: () => void;
  switchNetwork: (chainId: number, rpcUrl?: string, explorer?: string) => Promise<{ success: boolean; error?: string }>;
  sendTransaction: (transaction: { from?: string; to: string; value?: string; data?: string }) => Promise<{ success: boolean; txHash?: string; error?: string }>;
  getTokenBalance: (tokenAddress: string, ownerAddress: string) => Promise<{ success: boolean; balance?: string; error?: string }>;
}

const WalletContext = createContext<WalletContextType | undefined>(undefined);

export const WalletProvider = ({ children }: { children: ReactNode }) => {
  const wallet = useWallet();

  return (
    <WalletContext.Provider value={wallet}>
      {children}
    </WalletContext.Provider>
  );
};

export const useWalletContext = () => {
  const context = useContext(WalletContext);
  if (context === undefined) {
    throw new Error('useWalletContext must be used within a WalletProvider');
  }
  return context;
};
