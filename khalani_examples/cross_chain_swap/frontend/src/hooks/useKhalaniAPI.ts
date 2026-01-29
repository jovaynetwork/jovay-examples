import { useState, useCallback } from 'react';
import { khalaniAPI } from '../lib/khalani';
import {
  QuoteRequest,
  QuoteResponse,
  DepositBuildRequest,
  DepositPlan,
  SubmitDepositRequest,
  SubmitResponse,
  Order,
} from '../types';

/**
 * Hook for interacting with Khalani API
 * Manages loading states and error handling
 */
export const useKhalaniAPI = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => setError(null), []);

  const requestQuote = useCallback(
    async (request: QuoteRequest): Promise<{ success: boolean; data?: QuoteResponse; error?: string }> => {
      setIsLoading(true);
      setError(null);

      try {
        const validation = khalaniAPI.validateQuoteRequest(request);
        if (!validation.valid) {
          setError(validation.error || 'Invalid request');
          return { success: false, error: validation.error };
        }

        const data = await khalaniAPI.requestQuote(request);
        return { success: true, data };
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to request quote';
        setError(errorMessage);
        return { success: false, error: errorMessage };
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  const buildDeposit = useCallback(
    async (request: DepositBuildRequest): Promise<{ success: boolean; data?: DepositPlan; error?: string }> => {
      setIsLoading(true);
      setError(null);

      try {
        const data = await khalaniAPI.buildDeposit(request);
        return { success: true, data };
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to build deposit';
        setError(errorMessage);
        return { success: false, error: errorMessage };
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  const submitDeposit = useCallback(
    async (request: SubmitDepositRequest): Promise<{ success: boolean; data?: SubmitResponse; error?: string }> => {
      setIsLoading(true);
      setError(null);

      try {
        const data = await khalaniAPI.submitDeposit(request);
        return { success: true, data };
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to submit deposit';
        setError(errorMessage);
        return { success: false, error: errorMessage };
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  const getOrder = useCallback(
    async (address: string, orderId: string): Promise<{ success: boolean; data?: Order; error?: string }> => {
      setIsLoading(true);
      setError(null);

      try {
        const data = await khalaniAPI.getOrder(address, orderId);
        if (!data) {
          setError('Order not found');
          return { success: false, error: 'Order not found' };
        }
        return { success: true, data };
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to fetch order';
        setError(errorMessage);
        return { success: false, error: errorMessage };
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  const pollOrderStatus = useCallback(
    async (
      address: string,
      orderId: string,
      onUpdate?: (order: Order) => void
    ): Promise<{ success: boolean; data?: Order; error?: string }> => {
      setIsLoading(true);
      setError(null);

      try {
        const data = await khalaniAPI.pollOrderStatus(address, orderId, onUpdate);
        return { success: true, data };
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Failed to poll order status';
        setError(errorMessage);
        return { success: false, error: errorMessage };
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  return {
    isLoading,
    error,
    clearError,
    requestQuote,
    buildDeposit,
    submitDeposit,
    getOrder,
    pollOrderStatus,
  };
};
