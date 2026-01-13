// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { IRouterClient } from "@chainlink/contracts-ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/libraries/Client.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Sender
 * @notice A contract for sending cross-chain messages via Chainlink CCIP
 * @dev Supports both LINK and native token (ETH) fee payment
 *
 * Example usage:
 * 1. Deploy this contract on the source chain (e.g., Ethereum Sepolia)
 * 2. Fund the contract with LINK or native tokens for fees
 * 3. Call sendMessage() or sendMessagePayNative() to send cross-chain messages
 */
contract Sender {
    using SafeERC20 for IERC20;

    // ══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ══════════════════════════════════════════════════════════════════════════

    error NotOwner();
    error InvalidReceiverAddress();
    error InsufficientLinkBalance(uint256 required, uint256 available);
    error InsufficientNativeBalance(uint256 required, uint256 available);
    error FailedToWithdraw(address owner, uint256 amount);

    // ══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ══════════════════════════════════════════════════════════════════════════

    event MessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        string text,
        address feeToken,
        uint256 fees
    );

    // ══════════════════════════════════════════════════════════════════════════
    // STATE
    // ══════════════════════════════════════════════════════════════════════════

    IRouterClient private immutable I_ROUTER;
    IERC20 private immutable I_LINK_TOKEN;
    address private immutable I_OWNER;

    // ══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Constructor
     * @param _router The address of the CCIP Router contract
     * @param _link The address of the LINK token contract
     */
    constructor(address _router, address _link) {
        I_ROUTER = IRouterClient(_router);
        I_LINK_TOKEN = IERC20(_link);
        I_OWNER = msg.sender;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ══════════════════════════════════════════════════════════════════════════

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != I_OWNER) revert NotOwner();
    }

    // ══════════════════════════════════════════════════════════════════════════
    // EXTERNAL FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Send a message to a receiver on another chain (pay with LINK)
     * @param destinationChainSelector The chain selector of the destination chain
     * @param receiver The address of the receiver contract on the destination chain
     * @param text The message text to send
     * @return messageId The ID of the sent message
     *
     * @dev Before calling:
     *      1. Ensure the contract has sufficient LINK balance
     *      2. Get LINK from https://faucets.chain.link/
     */
    function sendMessage(uint64 destinationChainSelector, address receiver, string calldata text)
        external
        onlyOwner
        returns (bytes32 messageId)
    {
        if (receiver == address(0)) revert InvalidReceiverAddress();

        // Build the CCIP message
        Client.EVM2AnyMessage memory message = _buildCcipMessage(receiver, text, address(I_LINK_TOKEN));

        // Get the fee required
        uint256 fees = I_ROUTER.getFee(destinationChainSelector, message);

        // Check LINK balance
        uint256 linkBalance = I_LINK_TOKEN.balanceOf(address(this));
        if (fees > linkBalance) {
            revert InsufficientLinkBalance(fees, linkBalance);
        }

        // Approve the Router to spend LINK
        I_LINK_TOKEN.safeIncreaseAllowance(address(I_ROUTER), fees);

        // Send the message
        messageId = I_ROUTER.ccipSend(destinationChainSelector, message);

        emit MessageSent(messageId, destinationChainSelector, receiver, text, address(I_LINK_TOKEN), fees);
    }

    /**
     * @notice Send a message to a receiver on another chain (pay with native token)
     * @param destinationChainSelector The chain selector of the destination chain
     * @param receiver The address of the receiver contract on the destination chain
     * @param text The message text to send
     * @return messageId The ID of the sent message
     *
     * @dev Before calling:
     *      1. Ensure the contract has sufficient ETH balance
     *      2. Send ETH to this contract before calling
     */
    function sendMessagePayNative(uint64 destinationChainSelector, address receiver, string calldata text)
        external
        onlyOwner
        returns (bytes32 messageId)
    {
        if (receiver == address(0)) revert InvalidReceiverAddress();

        // Build the CCIP message with native token as fee
        Client.EVM2AnyMessage memory message = _buildCcipMessage(receiver, text, address(0));

        // Get the fee required
        uint256 fees = I_ROUTER.getFee(destinationChainSelector, message);

        // Check native balance
        if (fees > address(this).balance) {
            revert InsufficientNativeBalance(fees, address(this).balance);
        }

        // Send the message with native token fee
        messageId = I_ROUTER.ccipSend{ value: fees }(destinationChainSelector, message);

        emit MessageSent(messageId, destinationChainSelector, receiver, text, address(0), fees);
    }

    /**
     * @notice Estimate the fee for sending a message
     * @param destinationChainSelector The chain selector of the destination chain
     * @param receiver The address of the receiver contract
     * @param text The message text
     * @param payWithLink If true, estimate fee in LINK; if false, in native token
     * @return fee The estimated fee
     */
    function estimateFee(uint64 destinationChainSelector, address receiver, string calldata text, bool payWithLink)
        external
        view
        returns (uint256 fee)
    {
        address feeToken = payWithLink ? address(I_LINK_TOKEN) : address(0);
        Client.EVM2AnyMessage memory message = _buildCcipMessage(receiver, text, feeToken);
        fee = I_ROUTER.getFee(destinationChainSelector, message);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Build the CCIP message struct
     * @param receiver The receiver address on the destination chain
     * @param text The message text
     * @param feeToken The token used for fee payment (address(0) for native)
     * @return message The CCIP message struct
     */
    function _buildCcipMessage(address receiver, string calldata text, address feeToken)
        internal
        pure
        returns (Client.EVM2AnyMessage memory message)
    {
        message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(text),
            tokenAmounts: new Client.EVMTokenAmount[](0), // No tokens being transferred
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({ gasLimit: 200_000 }) // Additional gas for receiver execution
            ),
            feeToken: feeToken
        });
    }

    // ══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Withdraw LINK tokens from the contract
     * @param to The address to send the tokens to
     */
    function withdrawLink(address to) external onlyOwner {
        uint256 balance = I_LINK_TOKEN.balanceOf(address(this));
        I_LINK_TOKEN.safeTransfer(to, balance);
    }

    /**
     * @notice Withdraw native tokens from the contract
     * @param to The address to send the tokens to
     */
    function withdrawNative(address to) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success,) = to.call{ value: balance }("");
        if (!success) revert FailedToWithdraw(to, balance);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    function getRouter() external view returns (address) {
        return address(I_ROUTER);
    }

    function getLinkToken() external view returns (address) {
        return address(I_LINK_TOKEN);
    }

    function getOwner() external view returns (address) {
        return I_OWNER;
    }

    // Allow contract to receive ETH
    receive() external payable { }
}
