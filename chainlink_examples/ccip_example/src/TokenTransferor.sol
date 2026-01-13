// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { IRouterClient } from "@chainlink/contracts-ccip/interfaces/IRouterClient.sol";
import { Client } from "@chainlink/contracts-ccip/libraries/Client.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title TokenTransferor
 * @notice A contract for transferring tokens across chains via Chainlink CCIP
 * @dev Supports both LINK and native token (ETH) fee payment
 *
 * Example usage:
 * 1. Deploy this contract on the source chain
 * 2. Call allowlistDestinationChain() to enable the destination chain
 * 3. Fund the contract with LINK (for fees) and the tokens to transfer
 * 4. Call transferTokensPayLink() or transferTokensPayNative()
 */
contract TokenTransferor {
    using SafeERC20 for IERC20;

    // ══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ══════════════════════════════════════════════════════════════════════════

    error NotOwner();
    error InvalidReceiverAddress();
    error InvalidTokenAddress();
    error InvalidAmount();
    error DestinationChainNotAllowed(uint64 destinationChainSelector);
    error InsufficientLinkBalance(uint256 required, uint256 available);
    error InsufficientNativeBalance(uint256 required, uint256 available);
    error InsufficientTokenBalance(uint256 required, uint256 available);
    error FailedToWithdraw(address owner, uint256 amount);

    // ══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ══════════════════════════════════════════════════════════════════════════

    event TokensTransferred(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        address token,
        uint256 tokenAmount,
        address feeToken,
        uint256 fees
    );

    event DestinationChainAllowlisted(uint64 indexed chainSelector, bool allowed);

    // ══════════════════════════════════════════════════════════════════════════
    // STATE
    // ══════════════════════════════════════════════════════════════════════════

    IRouterClient private immutable I_ROUTER;
    IERC20 private immutable I_LINK_TOKEN;
    address private immutable I_OWNER;

    // Mapping to track allowed destination chains
    mapping(uint64 => bool) public allowlistedDestinationChains;

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

    modifier onlyAllowlistedDestination(uint64 _destinationChainSelector) {
        _onlyAllowlistedDestination(_destinationChainSelector);
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != I_OWNER) revert NotOwner();
    }

    function _onlyAllowlistedDestination(uint64 _destinationChainSelector) internal view {
        if (!allowlistedDestinationChains[_destinationChainSelector]) {
            revert DestinationChainNotAllowed(_destinationChainSelector);
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // EXTERNAL FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Allowlist a destination chain for token transfers
     * @param _destinationChainSelector The chain selector of the destination chain
     * @param allowed Whether to allow or disallow the chain
     */
    function allowlistDestinationChain(uint64 _destinationChainSelector, bool allowed) external onlyOwner {
        allowlistedDestinationChains[_destinationChainSelector] = allowed;
        emit DestinationChainAllowlisted(_destinationChainSelector, allowed);
    }

    /**
     * @notice Transfer tokens to a receiver on another chain (pay fees with LINK)
     * @param _destinationChainSelector The chain selector of the destination chain
     * @param _receiver The address to receive the tokens on the destination chain
     * @param _token The address of the token to transfer
     * @param _amount The amount of tokens to transfer
     * @return messageId The ID of the CCIP message
     *
     * @dev Before calling:
     *      1. Ensure the destination chain is allowlisted
     *      2. Transfer sufficient LINK to this contract for fees
     *      3. Transfer the tokens to be sent to this contract
     */
    function transferTokensPayLink(uint64 _destinationChainSelector, address _receiver, address _token, uint256 _amount)
        external
        onlyOwner
        onlyAllowlistedDestination(_destinationChainSelector)
        returns (bytes32 messageId)
    {
        // Validate inputs
        if (_receiver == address(0)) revert InvalidReceiverAddress();
        if (_token == address(0)) revert InvalidTokenAddress();
        if (_amount == 0) revert InvalidAmount();

        // Check token balance
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        if (_amount > tokenBalance) {
            revert InsufficientTokenBalance(_amount, tokenBalance);
        }

        // Build the CCIP message
        Client.EVM2AnyMessage memory message = _buildCcipMessage(_receiver, _token, _amount, address(I_LINK_TOKEN));

        // Get the fee required
        uint256 fees = I_ROUTER.getFee(_destinationChainSelector, message);

        // Check LINK balance
        uint256 linkBalance = I_LINK_TOKEN.balanceOf(address(this));
        if (fees > linkBalance) {
            revert InsufficientLinkBalance(fees, linkBalance);
        }

        // Approve the Router to spend LINK and tokens
        I_LINK_TOKEN.safeIncreaseAllowance(address(I_ROUTER), fees);
        IERC20(_token).safeIncreaseAllowance(address(I_ROUTER), _amount);

        // Send the message
        messageId = I_ROUTER.ccipSend(_destinationChainSelector, message);

        emit TokensTransferred(
            messageId, _destinationChainSelector, _receiver, _token, _amount, address(I_LINK_TOKEN), fees
        );
    }

    /**
     * @notice Transfer tokens to a receiver on another chain (pay fees with native token)
     * @param _destinationChainSelector The chain selector of the destination chain
     * @param _receiver The address to receive the tokens on the destination chain
     * @param _token The address of the token to transfer
     * @param _amount The amount of tokens to transfer
     * @return messageId The ID of the CCIP message
     *
     * @dev Before calling:
     *      1. Ensure the destination chain is allowlisted
     *      2. Send sufficient ETH to this contract for fees
     *      3. Transfer the tokens to be sent to this contract
     */
    function transferTokensPayNative(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount
    ) external onlyOwner onlyAllowlistedDestination(_destinationChainSelector) returns (bytes32 messageId) {
        // Validate inputs
        if (_receiver == address(0)) revert InvalidReceiverAddress();
        if (_token == address(0)) revert InvalidTokenAddress();
        if (_amount == 0) revert InvalidAmount();

        // Check token balance
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        if (_amount > tokenBalance) {
            revert InsufficientTokenBalance(_amount, tokenBalance);
        }

        // Build the CCIP message with native token as fee
        Client.EVM2AnyMessage memory message = _buildCcipMessage(_receiver, _token, _amount, address(0));

        // Get the fee required
        uint256 fees = I_ROUTER.getFee(_destinationChainSelector, message);

        // Check native balance
        if (fees > address(this).balance) {
            revert InsufficientNativeBalance(fees, address(this).balance);
        }

        // Approve the Router to spend tokens
        IERC20(_token).safeIncreaseAllowance(address(I_ROUTER), _amount);

        // Send the message with native token fee
        messageId = I_ROUTER.ccipSend{ value: fees }(_destinationChainSelector, message);

        emit TokensTransferred(messageId, _destinationChainSelector, _receiver, _token, _amount, address(0), fees);
    }

    /**
     * @notice Estimate the fee for transferring tokens
     * @param _destinationChainSelector The chain selector of the destination chain
     * @param _receiver The receiver address
     * @param _token The token address
     * @param _amount The token amount
     * @param payWithLink If true, estimate fee in LINK; if false, in native token
     * @return fee The estimated fee
     */
    function estimateFee(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount,
        bool payWithLink
    ) external view returns (uint256 fee) {
        address feeToken = payWithLink ? address(I_LINK_TOKEN) : address(0);
        Client.EVM2AnyMessage memory message = _buildCcipMessage(_receiver, _token, _amount, feeToken);
        fee = I_ROUTER.getFee(_destinationChainSelector, message);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Build the CCIP message struct for token transfer
     * @param _receiver The receiver address on the destination chain
     * @param _token The token to transfer
     * @param _amount The amount to transfer
     * @param _feeToken The token used for fee payment (address(0) for native)
     * @return message The CCIP message struct
     */
    function _buildCcipMessage(address _receiver, address _token, uint256 _amount, address _feeToken)
        internal
        pure
        returns (Client.EVM2AnyMessage memory message)
    {
        // Build token amounts array
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({ token: _token, amount: _amount });

        message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: "", // No additional data
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({ gasLimit: 0 }) // No additional execution on receiver
            ),
            feeToken: _feeToken
        });
    }

    // ══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Withdraw LINK tokens from the contract
     * @param _to The address to send the tokens to
     */
    function withdrawLink(address _to) external onlyOwner {
        uint256 balance = I_LINK_TOKEN.balanceOf(address(this));
        I_LINK_TOKEN.safeTransfer(_to, balance);
    }

    /**
     * @notice Withdraw native tokens from the contract
     * @param _to The address to send the tokens to
     */
    function withdrawNative(address _to) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success,) = _to.call{ value: balance }("");
        if (!success) revert FailedToWithdraw(_to, balance);
    }

    /**
     * @notice Withdraw ERC20 tokens from the contract
     * @param _token The token address
     * @param _to The address to send the tokens to
     */
    function withdrawToken(address _token, address _to) external onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(_to, balance);
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
