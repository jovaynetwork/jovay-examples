// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { Sender } from "../src/Sender.sol";

/**
 * @title DeploySender
 * @notice Deploy the Sender contract on the source chain
 *
 * Usage:
 *   # Deploy to Ethereum Sepolia
 *   forge script script/DeploySender.s.sol:DeploySender \
 *     --rpc-url sepolia \
 *     --broadcast \
 *     --verify
 *
 *   # Deploy to Jovay Testnet
 *   ROUTER=$JOVAY_ROUTER LINK=$JOVAY_LINK \
 *   forge script script/DeploySender.s.sol:DeploySender \
 *     --rpc-url jovay_testnet \
 *     --broadcast
 */
contract DeploySender is Script {
    // Default values for Ethereum Sepolia
    address constant SEPOLIA_ROUTER = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address constant SEPOLIA_LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // Jovay Testnet values
    address constant JOVAY_ROUTER = 0x2016AA303B331bd739Fd072998e579a3052500A6;
    address constant JOVAY_LINK = 0xd3e461C55676B10634a5F81b747c324B85686Dd1;

    function run() external {
        // Get router and link addresses from env or use defaults
        address router = vm.envOr("ROUTER", SEPOLIA_ROUTER);
        address link = vm.envOr("LINK", SEPOLIA_LINK);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying Sender contract...");
        console.log("Router:", router);
        console.log("LINK:", link);

        vm.startBroadcast(deployerPrivateKey);

        Sender sender = new Sender(router, link);

        vm.stopBroadcast();

        console.log("Sender deployed at:", address(sender));
        console.log("");
        console.log("Next steps:");
        console.log("1. Fund the contract with LINK tokens for fees");
        console.log("2. Or send ETH if using native token for fees");
        console.log("3. Call sendMessage() or sendMessagePayNative()");
    }
}

/**
 * @title DeploySenderSepolia
 * @notice Convenience script for deploying to Sepolia with hardcoded values
 */
contract DeploySenderSepolia is Script {
    address constant ROUTER = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address constant LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying Sender to Ethereum Sepolia...");

        vm.startBroadcast(deployerPrivateKey);
        Sender sender = new Sender(ROUTER, LINK);
        vm.stopBroadcast();

        console.log("Sender deployed at:", address(sender));
    }
}

/**
 * @title DeploySenderJovay
 * @notice Convenience script for deploying to Jovay Testnet with hardcoded values
 */
contract DeploySenderJovay is Script {
    address constant ROUTER = 0x2016AA303B331bd739Fd072998e579a3052500A6;
    address constant LINK = 0xd3e461C55676B10634a5F81b747c324B85686Dd1;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying Sender to Jovay Testnet...");

        vm.startBroadcast(deployerPrivateKey);
        Sender sender = new Sender(ROUTER, LINK);
        vm.stopBroadcast();

        console.log("Sender deployed at:", address(sender));
    }
}
