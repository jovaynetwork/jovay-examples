// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { Receiver } from "../src/Receiver.sol";

/**
 * @title DeployReceiver
 * @notice Deploy the Receiver contract on the destination chain
 *
 * Usage:
 *   # Deploy to Jovay Testnet (receive messages from Sepolia)
 *   forge script script/DeployReceiver.s.sol:DeployReceiver \
 *     --rpc-url jovay_testnet \
 *     --broadcast
 *
 *   # Deploy to Ethereum Sepolia (receive messages from Jovay)
 *   ROUTER=$SEPOLIA_ROUTER \
 *   forge script script/DeployReceiver.s.sol:DeployReceiver \
 *     --rpc-url sepolia \
 *     --broadcast
 */
contract DeployReceiver is Script {
    // Default to Jovay Testnet
    address constant JOVAY_ROUTER = 0x2016AA303B331bd739Fd072998e579a3052500A6;

    function run() external {
        // Get router address from env or use default
        address router = vm.envOr("ROUTER", JOVAY_ROUTER);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying Receiver contract...");
        console.log("Router:", router);

        vm.startBroadcast(deployerPrivateKey);

        Receiver receiver = new Receiver(router);

        vm.stopBroadcast();

        console.log("Receiver deployed at:", address(receiver));
        console.log("");
        console.log("Next steps:");
        console.log("1. Use the Sender contract to send a message to this address");
        console.log("2. Track the message on https://ccip.chain.link/");
        console.log("3. Call getLastReceivedMessageDetails() to verify receipt");
    }
}

/**
 * @title DeployReceiverJovay
 * @notice Convenience script for deploying to Jovay Testnet
 */
contract DeployReceiverJovay is Script {
    address constant ROUTER = 0x2016AA303B331bd739Fd072998e579a3052500A6;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying Receiver to Jovay Testnet...");

        vm.startBroadcast(deployerPrivateKey);
        Receiver receiver = new Receiver(ROUTER);
        vm.stopBroadcast();

        console.log("Receiver deployed at:", address(receiver));
    }
}

/**
 * @title DeployReceiverSepolia
 * @notice Convenience script for deploying to Ethereum Sepolia
 */
contract DeployReceiverSepolia is Script {
    address constant ROUTER = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying Receiver to Ethereum Sepolia...");

        vm.startBroadcast(deployerPrivateKey);
        Receiver receiver = new Receiver(ROUTER);
        vm.stopBroadcast();

        console.log("Receiver deployed at:", address(receiver));
    }
}
