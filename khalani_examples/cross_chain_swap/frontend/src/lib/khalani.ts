import {
  QuoteRequest,
  QuoteResponse,
  DepositBuildRequest,
  DepositPlan,
  SubmitDepositRequest,
  SubmitResponse,
  OrdersResponse,
  Order,
} from '../types';
import { KHALANI_API_BASE_URL } from '../config';

/**
 * Khalani API Client
 * Handles all interactions with Khalani Intent Markets API
 */
class KhalaniAPI {
  private baseUrl: string;

  constructor(baseUrl: string = KHALANI_API_BASE_URL) {
    this.baseUrl = baseUrl;
  }

  /**
   * Generic fetch wrapper with error handling
   */
  private async fetchJson<T>(url: string, init?: RequestInit): Promise<T> {
    const res = await fetch(url, init);
    if (!res.ok) {
      const text = await res.text().catch(() => '');
      throw new Error(`${res.status} ${res.statusText}: ${text || 'Request failed'}`);
    }
    return (await res.json()) as T;
  }

  /**
   * Request a cross-chain quote
   */
  async requestQuote(request: QuoteRequest): Promise<QuoteResponse> {
    return this.fetchJson<QuoteResponse>(`${this.baseUrl}/v1/quotes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(request),
    });
  }

  /**
   * Build a deposit plan (wallet actions)
   */
  async buildDeposit(request: DepositBuildRequest): Promise<DepositPlan> {
    return this.fetchJson<DepositPlan>(`${this.baseUrl}/v1/deposit/build`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(request),
    });
  }

  /**
   * Submit the deposit transaction hash (create order)
   */
  async submitDeposit(request: SubmitDepositRequest): Promise<SubmitResponse> {
    return this.fetchJson<SubmitResponse>(`${this.baseUrl}/v1/deposit/submit`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(request),
    });
  }

  /**
   * Get order status for a specific order
   */
  async getOrder(address: string, orderId: string): Promise<Order | undefined> {
    const response = await this.fetchJson<OrdersResponse>(
      `${this.baseUrl}/v1/orders/${address}?orderIds=${encodeURIComponent(orderId)}`
    );
    return response.data?.[0];
  }

  /**
   * Poll order status until it reaches a terminal state
   */
  async pollOrderStatus(
    address: string,
    orderId: string,
    onUpdate?: (order: Order) => void,
    pollingInterval = 5000,
    maxPolls = 24
  ): Promise<Order> {
    const terminalStatuses = new Set<Order['status']>(['filled', 'refunded', 'failed']);

    let lastOrder: Order | undefined;

    for (let i = 0; i < maxPolls; i++) {
      const order = await this.getOrder(address, orderId);

      if (!order) {
        throw new Error(`Order ${orderId} not found`);
      }

      // Notify on status change
      if (!lastOrder || order.status !== lastOrder.status) {
        onUpdate?.(order);
        lastOrder = order;
      }

      // Check if terminal status reached
      if (terminalStatuses.has(order.status)) {
        return order;
      }

      // Wait before next poll
      if (i < maxPolls - 1) {
        await new Promise((resolve) => setTimeout(resolve, pollingInterval));
      }
    }

    // Return last known order if max polls reached
    if (!lastOrder) {
      throw new Error('Failed to fetch order status');
    }

    return lastOrder;
  }

  /**
   * Check if a quote is still valid
   */
  isQuoteValid(validBefore: number): boolean {
    const nowUnix = Math.floor(Date.now() / 1000);
    return nowUnix < validBefore;
  }

  /**
   * Validate and sanitize a quote request
   */
  validateQuoteRequest(request: QuoteRequest): { valid: boolean; error?: string } {
    if (!request.fromAddress || !request.fromAddress.startsWith('0x')) {
      return { valid: false, error: 'Invalid from address' };
    }

    if (request.fromChainId === request.toChainId) {
      return { valid: false, error: 'Source and destination chains must be different' };
    }

    if (!request.fromToken || !request.toToken) {
      return { valid: false, error: 'Token addresses are required' };
    }

    try {
      const amount = BigInt(request.amount);
      if (amount === BigInt(0)) {
        return { valid: false, error: 'Amount must be greater than 0' };
      }
    } catch {
      return { valid: false, error: 'Invalid amount format' };
    }

    if (
      request.tradeType !== 'EXACT_INPUT' &&
      request.tradeType !== 'EXACT_OUTPUT'
    ) {
      return { valid: false, error: 'Invalid trade type' };
    }

    return { valid: true };
  }
}

// Export singleton instance
export const khalaniAPI = new KhalaniAPI();

// Export class for testing
export default KhalaniAPI;
