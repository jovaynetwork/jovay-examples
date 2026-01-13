// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { TokenTransferor } from "../src/TokenTransferor.sol";

/**
 * @title DeployTokenTransferor
 * @notice Deploy the TokenTransferor contract for cross-chain token transfers
 *
 * Usage:
 *   # Deploy to Ethereum Sepolia
 *   forge script script/DeployTokenTransferor.s.sol:DeployTokenTransferor \
 *     --rpc-url sepolia \
 *     --broadcast
 *
 *   # Deploy to Jovay Testnet
 *   ROUTER=$JOVAY_ROUTER LINK=$JOVAY_LINK \
 *   forge script script/DeployTokenTransferor.s.sol:DeployTokenTransferor \
 *     --rpc-url jovay_testnet \
 *     --broadcast
 */
contract DeployTokenTransferor is Script {
    // Default values for Ethereum Sepolia
    address constant SEPOLIA_ROUTER = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address constant SEPOLIA_LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    function run() external {
        address router = vm.envOr("ROUTER", SEPOLIA_ROUTER);
        address link = vm.envOr("LINK", SEPOLIA_LINK);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying TokenTransferor contract...");
        console.log("Router:", router);
        console.log("LINK:", link);

        vm.startBroadcast(deployerPrivateKey);

        TokenTransferor transferor = new TokenTransferor(router, link);

        vm.stopBroadcast();

        console.log("TokenTransferor deployed at:", address(transferor));
        console.log("");
        console.log("Next steps:");
        console.log("1. Call allowlistDestinationChain() to enable the destination");
        console.log("2. Fund the contract with LINK and tokens to transfer");
        console.log("3. Call transferTokensPayLink() or transferTokensPayNative()");
    }
}

/**
 * @title DeployTokenTransferorSepolia
 * @notice Deploy TokenTransferor to Ethereum Sepolia with hardcoded values
 */
contract DeployTokenTransferorSepolia is Script {
    address constant ROUTER = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address constant LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying TokenTransferor to Ethereum Sepolia...");

        vm.startBroadcast(deployerPrivateKey);
        TokenTransferor transferor = new TokenTransferor(ROUTER, LINK);
        vm.stopBroadcast();

        console.log("TokenTransferor deployed at:", address(transferor));
    }
}

/**
 * @title DeployTokenTransferorJovay
 * @notice Deploy TokenTransferor to Jovay Testnet with hardcoded values
 */
contract DeployTokenTransferorJovay is Script {
    address constant ROUTER = 0x2016AA303B331bd739Fd072998e579a3052500A6;
    address constant LINK = 0xd3e461C55676B10634a5F81b747c324B85686Dd1;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        console.log("Deploying TokenTransferor to Jovay Testnet...");

        vm.startBroadcast(deployerPrivateKey);
        TokenTransferor transferor = new TokenTransferor(ROUTER, LINK);
        vm.stopBroadcast();

        console.log("TokenTransferor deployed at:", address(transferor));
    }
}
