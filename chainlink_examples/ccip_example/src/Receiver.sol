// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { CCIPReceiver } from "@chainlink/contracts-ccip/applications/CCIPReceiver.sol";
import { Client } from "@chainlink/contracts-ccip/libraries/Client.sol";

/**
 * @title Receiver
 * @notice A contract for receiving cross-chain messages via Chainlink CCIP
 *
 * Example usage:
 * 1. Deploy this contract on the destination chain (e.g., Jovay Testnet)
 * 2. Use the Sender contract on the source chain to send messages
 * 3. Call getLastReceivedMessageDetails() to verify received messages
 */
contract Receiver is CCIPReceiver {
    // ══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ══════════════════════════════════════════════════════════════════════════

    error NotOwner();
    error SourceChainNotAllowed(uint64 sourceChainSelector);
    error SenderNotAllowed(address sender);

    // ══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ══════════════════════════════════════════════════════════════════════════

    event MessageReceived(bytes32 indexed messageId, uint64 indexed sourceChainSelector, address sender, string text);

    // ══════════════════════════════════════════════════════════════════════════
    // STATE
    // ══════════════════════════════════════════════════════════════════════════

    address private immutable I_OWNER;

    // Store received message details
    bytes32 private sLastMessageId;
    uint64 private sLastSourceChainSelector;
    address private sLastSender;
    string private sLastMessage;

    // Message history
    struct ReceivedMessage {
        bytes32 messageId;
        uint64 sourceChainSelector;
        address sender;
        string text;
        uint256 timestamp;
    }

    ReceivedMessage[] private sMessageHistory;

    // Allowlists for security (optional - can be disabled)
    mapping(uint64 => bool) public allowlistedSourceChains;
    mapping(address => bool) public allowlistedSenders;
    bool public allowlistEnabled;

    // ══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Constructor
     * @param _router The address of the CCIP Router contract on this chain
     */
    constructor(address _router) CCIPReceiver(_router) {
        I_OWNER = msg.sender;
        allowlistEnabled = false; // Disabled by default for easier testing
    }

    // ══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ══════════════════════════════════════════════════════════════════════════

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        _onlyAllowlisted(_sourceChainSelector, _sender);
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != I_OWNER) revert NotOwner();
    }

    function _onlyAllowlisted(uint64 _sourceChainSelector, address _sender) internal view {
        if (allowlistEnabled) {
            if (!allowlistedSourceChains[_sourceChainSelector]) {
                revert SourceChainNotAllowed(_sourceChainSelector);
            }
            if (!allowlistedSenders[_sender]) {
                revert SenderNotAllowed(_sender);
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    // CCIP RECEIVE
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Called by the CCIP Router when a message is received
     * @param message The CCIP message containing sender info and data
     */
    function _ccipReceive(Client.Any2EVMMessage memory message)
        internal
        override
        onlyAllowlisted(message.sourceChainSelector, abi.decode(message.sender, (address)))
    {
        // Decode the sender address
        address sender = abi.decode(message.sender, (address));

        // Decode the message text
        string memory text = abi.decode(message.data, (string));

        // Store the last received message details
        sLastMessageId = message.messageId;
        sLastSourceChainSelector = message.sourceChainSelector;
        sLastSender = sender;
        sLastMessage = text;

        // Add to message history
        sMessageHistory.push(
            ReceivedMessage({
                messageId: message.messageId,
                sourceChainSelector: message.sourceChainSelector,
                sender: sender,
                text: text,
                timestamp: block.timestamp
            })
        );

        emit MessageReceived(message.messageId, message.sourceChainSelector, sender, text);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Get the details of the last received message
     * @return messageId The ID of the last received message
     * @return text The text of the last received message
     */
    function getLastReceivedMessageDetails() external view returns (bytes32 messageId, string memory text) {
        return (sLastMessageId, sLastMessage);
    }

    /**
     * @notice Get full details of the last received message
     * @return messageId The message ID
     * @return sourceChainSelector The source chain selector
     * @return sender The sender address
     * @return text The message text
     */
    function getLastReceivedMessageFull()
        external
        view
        returns (bytes32 messageId, uint64 sourceChainSelector, address sender, string memory text)
    {
        return (sLastMessageId, sLastSourceChainSelector, sLastSender, sLastMessage);
    }

    /**
     * @notice Get the number of messages received
     * @return The total count of received messages
     */
    function getMessageCount() external view returns (uint256) {
        return sMessageHistory.length;
    }

    /**
     * @notice Get a specific message from history
     * @param index The index of the message in history
     * @return The received message details
     */
    function getMessage(uint256 index) external view returns (ReceivedMessage memory) {
        require(index < sMessageHistory.length, "Index out of bounds");
        return sMessageHistory[index];
    }

    /**
     * @notice Get all received messages
     * @return Array of all received messages
     */
    function getAllMessages() external view returns (ReceivedMessage[] memory) {
        return sMessageHistory;
    }

    function getOwner() external view returns (address) {
        return I_OWNER;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @notice Enable or disable the allowlist
     * @param enabled Whether to enable allowlist checking
     */
    function setAllowlistEnabled(bool enabled) external onlyOwner {
        allowlistEnabled = enabled;
    }

    /**
     * @notice Allowlist a source chain
     * @param _sourceChainSelector The chain selector to allowlist
     * @param allowed Whether to allow or disallow
     */
    function allowlistSourceChain(uint64 _sourceChainSelector, bool allowed) external onlyOwner {
        allowlistedSourceChains[_sourceChainSelector] = allowed;
    }

    /**
     * @notice Allowlist a sender address
     * @param _sender The sender address to allowlist
     * @param allowed Whether to allow or disallow
     */
    function allowlistSender(address _sender, bool allowed) external onlyOwner {
        allowlistedSenders[_sender] = allowed;
    }
}
