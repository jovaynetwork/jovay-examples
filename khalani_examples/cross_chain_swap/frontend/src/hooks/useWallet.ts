import { useState, useCallback, useEffect } from 'react';

/**
 * Hook for wallet integration
 * Manages EIP-1193 wallet connection and interactions
 */
export const useWallet = () => {
  const [address, setAddress] = useState<string | null>(null);
  const [chainId, setChainId] = useState<number | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const [isConnecting, setIsConnecting] = useState(false);

  // Check if window.ethereum is available
  const getEthereum = useCallback(() => {
    if (typeof window !== 'undefined' && (window as any).ethereum) {
      return (window as any).ethereum as {
        request: (args: { method: string; params?: unknown[] }) => Promise<unknown>;
        on: (event: string, handler: (...args: unknown[]) => void) => void;
        removeListener: (event: string, handler: (...args: unknown[]) => void) => void;
      };
    }
    return null;
  }, []);

  // Connect wallet
  const connect = useCallback(async (): Promise<{ success: boolean; address?: string; error?: string }> => {
    const ethereum = getEthereum();
    if (!ethereum) {
      return { success: false, error: 'No Ethereum wallet found. Please install MetaMask or another EIP-1193 compatible wallet.' };
    }

    setIsConnecting(true);

    try {
      const accounts = (await ethereum.request({
        method: 'eth_requestAccounts',
      })) as string[];

      if (!accounts || accounts.length === 0) {
        return { success: false, error: 'No accounts found' };
      }

      const account = accounts[0].toLowerCase();
      setAddress(account);
      setIsConnected(true);

      // Get current chain ID
      const currentChainId = (await ethereum.request({
        method: 'eth_chainId',
      })) as string;
      setChainId(parseInt(currentChainId, 16));

      return { success: true, address: account };
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to connect wallet';
      return { success: false, error: errorMessage };
    } finally {
      setIsConnecting(false);
    }
  }, [getEthereum]);

  // Disconnect wallet
  const disconnect = useCallback(() => {
    setAddress(null);
    setChainId(null);
    setIsConnected(false);
  }, []);

  // Switch network
  const switchNetwork = useCallback(
    async (
      targetChainId: number,
      rpcUrl?: string,
      explorer?: string
    ): Promise<{ success: boolean; error?: string }> => {
      const ethereum = getEthereum();
      if (!ethereum) {
        return { success: false, error: 'No wallet found' };
      }

      try {
        const chainIdHex = `0x${targetChainId.toString(16)}`;

        // Try to switch to the network
        await ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: chainIdHex }],
        });

        setChainId(targetChainId);
        return { success: true };
      } catch (switchError: unknown) {
        // If the network doesn't exist, try to add it
        if (
          typeof switchError === 'object' &&
          switchError !== null &&
          'code' in switchError &&
          (switchError as { code: number }).code === 4902
        ) {
          if (!rpcUrl || !explorer) {
            return { success: false, error: 'Network not found in wallet. RPC URL and explorer URL required to add network.' };
          }

          try {
            await ethereum.request({
              method: 'wallet_addEthereumChain',
              params: [
                {
                  chainId: `0x${targetChainId.toString(16)}`,
                  chainName: targetChainId === 1 ? 'Ethereum Mainnet' : 'Jovay Network',
                  nativeCurrency: {
                    name: 'ETH',
                    symbol: 'ETH',
                    decimals: 18,
                  },
                  rpcUrls: [rpcUrl],
                  blockExplorerUrls: [explorer],
                },
              ],
            });

            setChainId(targetChainId);
            return { success: true };
          } catch (addError) {
            const errorMessage = addError instanceof Error ? addError.message : 'Failed to add network';
            return { success: false, error: errorMessage };
          }
        }

        const errorMessage = switchError instanceof Error ? switchError.message : 'Failed to switch network';
        return { success: false, error: errorMessage };
      }
    },
    [getEthereum]
  );

  // Execute transaction
  const sendTransaction = useCallback(
    async (
      transaction: {
        from?: string;
        to: string;
        value?: string;
        data?: string;
      }
    ): Promise<{ success: boolean; txHash?: string; error?: string }> => {
      const ethereum = getEthereum();
      if (!ethereum) {
        return { success: false, error: 'No wallet found' };
      }

      try {
        const txHash = (await ethereum.request({
          method: 'eth_sendTransaction',
          params: [transaction],
        })) as string;

        return { success: true, txHash };
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to send transaction';
        return { success: false, error: errorMessage };
      }
    },
    [getEthereum]
  );

  // Get token balance
  const getTokenBalance = useCallback(
    async (tokenAddress: string, ownerAddress: string): Promise<{ success: boolean; balance?: string; error?: string }> => {
      const ethereum = getEthereum();
      if (!ethereum) {
        return { success: false, error: 'No wallet found' };
      }

      try {
        if (tokenAddress === '0x0000000000000000000000000000000000000000' || tokenAddress === '0x0') {
          // Native token balance
          const balance = (await ethereum.request({
            method: 'eth_getBalance',
            params: [ownerAddress, 'latest'],
          })) as string;

          return { success: true, balance };
        } else {
          // ERC-20 token balance
          const balanceOfData = {
            to: tokenAddress,
            data: `0x70a0823100000000000000000000000000000000000000000000000000000000000000000${ownerAddress.slice(2).padStart(64, '0')}`,
          };

          const balance = (await ethereum.request({
            method: 'eth_call',
            params: [balanceOfData, 'latest'],
          })) as string;

          return { success: true, balance };
        }
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to get token balance';
        return { success: false, error: errorMessage };
      }
    },
    [getEthereum]
  );

  // Listen for account and chain changes
  useEffect(() => {
    const ethereum = getEthereum();
    if (!ethereum) return;

    const handleAccountsChanged = (accounts: string[]) => {
      if (accounts.length === 0) {
        setAddress(null);
        setIsConnected(false);
      } else {
        setAddress(accounts[0].toLowerCase());
        setIsConnected(true);
      }
    };

    const handleChainChanged = (chainId: string) => {
      setChainId(parseInt(chainId, 16));
    };

    ethereum.on('accountsChanged', handleAccountsChanged as (...args: unknown[]) => void);
    ethereum.on('chainChanged', handleChainChanged as (...args: unknown[]) => void);

    // Check if already connected on mount
    const checkConnection = async () => {
      const accounts = (await ethereum.request({ method: 'eth_accounts' })) as string[];
      if (accounts.length > 0) {
        setAddress(accounts[0].toLowerCase());
        setIsConnected(true);

        const currentChainId = (await ethereum.request({ method: 'eth_chainId' })) as string;
        setChainId(parseInt(currentChainId, 16));
      }
    };

    checkConnection();

    return () => {
      ethereum.removeListener('accountsChanged', handleAccountsChanged as (...args: unknown[]) => void);
      ethereum.removeListener('chainChanged', handleChainChanged as (...args: unknown[]) => void);
    };
  }, [getEthereum]);

  return {
    address,
    chainId,
    isConnected,
    isConnecting,
    connect,
    disconnect,
    switchNetwork,
    sendTransaction,
    getTokenBalance,
  };
};
