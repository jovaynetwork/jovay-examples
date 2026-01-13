// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { Sender } from "../src/Sender.sol";

/**
 * @title SendMessage
 * @notice Send a cross-chain message using the Sender contract
 *
 * Usage:
 *   # Send message from Sepolia to Jovay Testnet
 *   SENDER_ADDRESS=0x... \
 *   RECEIVER_ADDRESS=0x... \
 *   MESSAGE="Hello from Ethereum!" \
 *   forge script script/SendMessage.s.sol:SendMessageToJovay \
 *     --rpc-url sepolia \
 *     --broadcast
 *
 *   # Send message from Jovay to Sepolia
 *   SENDER_ADDRESS=0x... \
 *   RECEIVER_ADDRESS=0x... \
 *   MESSAGE="Hello from Jovay!" \
 *   forge script script/SendMessage.s.sol:SendMessageToSepolia \
 *     --rpc-url jovay_testnet \
 *     --broadcast
 */

/**
 * @title SendMessageToJovay
 * @notice Send a message from Sepolia to Jovay Testnet (pay with LINK)
 */
contract SendMessageToJovay is Script {
    uint64 constant JOVAY_CHAIN_SELECTOR = 945045181441419236;

    function run() external {
        address senderAddress = vm.envAddress("SENDER_ADDRESS");
        address receiverAddress = vm.envAddress("RECEIVER_ADDRESS");
        string memory message = vm.envOr("MESSAGE", string("Hello from Ethereum Sepolia!"));

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        Sender sender = Sender(payable(senderAddress));

        console.log("Sending message to Jovay Testnet...");
        console.log("Sender contract:", senderAddress);
        console.log("Receiver contract:", receiverAddress);
        console.log("Message:", message);
        console.log("Chain selector:", JOVAY_CHAIN_SELECTOR);

        // Estimate fee first
        uint256 fee = sender.estimateFee(JOVAY_CHAIN_SELECTOR, receiverAddress, message, true);
        console.log("Estimated LINK fee:", fee);

        vm.startBroadcast(deployerPrivateKey);

        bytes32 messageId = sender.sendMessage(JOVAY_CHAIN_SELECTOR, receiverAddress, message);

        vm.stopBroadcast();

        console.log("");
        console.log("Message sent successfully!");
        console.log("Message ID:", vm.toString(messageId));
        console.log("");
        console.log("Track your message at:");
        console.log("https://ccip.chain.link/");
    }
}

/**
 * @title SendMessageToJovayPayNative
 * @notice Send a message from Sepolia to Jovay Testnet (pay with ETH)
 */
contract SendMessageToJovayPayNative is Script {
    uint64 constant JOVAY_CHAIN_SELECTOR = 945045181441419236;

    function run() external {
        address senderAddress = vm.envAddress("SENDER_ADDRESS");
        address receiverAddress = vm.envAddress("RECEIVER_ADDRESS");
        string memory message = vm.envOr("MESSAGE", string("Hello from Ethereum Sepolia!"));

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        Sender sender = Sender(payable(senderAddress));

        console.log("Sending message to Jovay Testnet (paying with ETH)...");
        console.log("Sender contract:", senderAddress);
        console.log("Receiver contract:", receiverAddress);
        console.log("Message:", message);

        // Estimate fee
        uint256 fee = sender.estimateFee(JOVAY_CHAIN_SELECTOR, receiverAddress, message, false);
        console.log("Estimated ETH fee:", fee);

        vm.startBroadcast(deployerPrivateKey);

        bytes32 messageId = sender.sendMessagePayNative(JOVAY_CHAIN_SELECTOR, receiverAddress, message);

        vm.stopBroadcast();

        console.log("");
        console.log("Message sent successfully!");
        console.log("Message ID:", vm.toString(messageId));
    }
}

/**
 * @title SendMessageToSepolia
 * @notice Send a message from Jovay Testnet to Sepolia (pay with LINK)
 */
contract SendMessageToSepolia is Script {
    uint64 constant SEPOLIA_CHAIN_SELECTOR = 16015286601757825753;

    function run() external {
        address senderAddress = vm.envAddress("SENDER_ADDRESS");
        address receiverAddress = vm.envAddress("RECEIVER_ADDRESS");
        string memory message = vm.envOr("MESSAGE", string("Hello from Jovay Testnet!"));

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        Sender sender = Sender(payable(senderAddress));

        console.log("Sending message to Ethereum Sepolia...");
        console.log("Sender contract:", senderAddress);
        console.log("Receiver contract:", receiverAddress);
        console.log("Message:", message);
        console.log("Chain selector:", SEPOLIA_CHAIN_SELECTOR);

        // Estimate fee
        uint256 fee = sender.estimateFee(SEPOLIA_CHAIN_SELECTOR, receiverAddress, message, true);
        console.log("Estimated LINK fee:", fee);

        vm.startBroadcast(deployerPrivateKey);

        bytes32 messageId = sender.sendMessage(SEPOLIA_CHAIN_SELECTOR, receiverAddress, message);

        vm.stopBroadcast();

        console.log("");
        console.log("Message sent successfully!");
        console.log("Message ID:", vm.toString(messageId));
        console.log("");
        console.log("Track your message at:");
        console.log("https://ccip.chain.link/");
    }
}
