// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { TokenTransferor } from "../src/TokenTransferor.sol";

/**
 * @title TransferToken
 * @notice Transfer tokens cross-chain using the TokenTransferor contract
 *
 * Usage:
 *   # Transfer BnM tokens from Sepolia to Jovay Testnet
 *   TOKEN_TRANSFEROR=0x... \
 *   RECEIVER=0x... \
 *   AMOUNT=2000000000000000 \
 *   forge script script/TransferToken.s.sol:TransferTokenToJovay \
 *     --rpc-url sepolia \
 *     --broadcast
 */

/**
 * @title AllowlistJovay
 * @notice Allowlist Jovay Testnet as a destination chain on Sepolia
 */
contract AllowlistJovay is Script {
    uint64 constant JOVAY_CHAIN_SELECTOR = 945045181441419236;

    function run() external {
        address transferorAddress = vm.envAddress("TOKEN_TRANSFEROR");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        TokenTransferor transferor = TokenTransferor(payable(transferorAddress));

        console.log("Allowlisting Jovay Testnet as destination...");
        console.log("TokenTransferor:", transferorAddress);
        console.log("Chain selector:", JOVAY_CHAIN_SELECTOR);

        vm.startBroadcast(deployerPrivateKey);

        transferor.allowlistDestinationChain(JOVAY_CHAIN_SELECTOR, true);

        vm.stopBroadcast();

        console.log("Jovay Testnet allowlisted successfully!");
    }
}

/**
 * @title AllowlistSepolia
 * @notice Allowlist Ethereum Sepolia as a destination chain on Jovay
 */
contract AllowlistSepolia is Script {
    uint64 constant SEPOLIA_CHAIN_SELECTOR = 16015286601757825753;

    function run() external {
        address transferorAddress = vm.envAddress("TOKEN_TRANSFEROR");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        TokenTransferor transferor = TokenTransferor(payable(transferorAddress));

        console.log("Allowlisting Ethereum Sepolia as destination...");
        console.log("TokenTransferor:", transferorAddress);
        console.log("Chain selector:", SEPOLIA_CHAIN_SELECTOR);

        vm.startBroadcast(deployerPrivateKey);

        transferor.allowlistDestinationChain(SEPOLIA_CHAIN_SELECTOR, true);

        vm.stopBroadcast();

        console.log("Ethereum Sepolia allowlisted successfully!");
    }
}

/**
 * @title TransferTokenToJovay
 * @notice Transfer tokens from Sepolia to Jovay Testnet (pay with LINK)
 */
contract TransferTokenToJovay is Script {
    uint64 constant JOVAY_CHAIN_SELECTOR = 945045181441419236;
    // CCIP-BnM test token on Sepolia
    address constant SEPOLIA_BNM = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;

    function run() external {
        address transferorAddress = vm.envAddress("TOKEN_TRANSFEROR");
        address receiverAddress = vm.envAddress("RECEIVER");
        uint256 amount = vm.envOr("AMOUNT", uint256(2000000000000000)); // 0.002 BnM
        address token = vm.envOr("TOKEN", SEPOLIA_BNM);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        TokenTransferor transferor = TokenTransferor(payable(transferorAddress));

        console.log("Transferring tokens to Jovay Testnet...");
        console.log("TokenTransferor:", transferorAddress);
        console.log("Receiver:", receiverAddress);
        console.log("Token:", token);
        console.log("Amount:", amount);

        // Estimate fee
        uint256 fee = transferor.estimateFee(JOVAY_CHAIN_SELECTOR, receiverAddress, token, amount, true);
        console.log("Estimated LINK fee:", fee);

        vm.startBroadcast(deployerPrivateKey);

        bytes32 messageId = transferor.transferTokensPayLink(JOVAY_CHAIN_SELECTOR, receiverAddress, token, amount);

        vm.stopBroadcast();

        console.log("");
        console.log("Token transfer initiated!");
        console.log("Message ID:", vm.toString(messageId));
        console.log("");
        console.log("Track your transfer at:");
        console.log("https://ccip.chain.link/");
    }
}

/**
 * @title TransferTokenToJovayPayNative
 * @notice Transfer tokens from Sepolia to Jovay Testnet (pay with ETH)
 */
contract TransferTokenToJovayPayNative is Script {
    uint64 constant JOVAY_CHAIN_SELECTOR = 945045181441419236;
    address constant SEPOLIA_BNM = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;

    function run() external {
        address transferorAddress = vm.envAddress("TOKEN_TRANSFEROR");
        address receiverAddress = vm.envAddress("RECEIVER");
        uint256 amount = vm.envOr("AMOUNT", uint256(2000000000000000));
        address token = vm.envOr("TOKEN", SEPOLIA_BNM);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        TokenTransferor transferor = TokenTransferor(payable(transferorAddress));

        console.log("Transferring tokens to Jovay Testnet (paying with ETH)...");
        console.log("TokenTransferor:", transferorAddress);
        console.log("Receiver:", receiverAddress);
        console.log("Token:", token);
        console.log("Amount:", amount);

        // Estimate fee
        uint256 fee = transferor.estimateFee(JOVAY_CHAIN_SELECTOR, receiverAddress, token, amount, false);
        console.log("Estimated ETH fee:", fee);

        vm.startBroadcast(deployerPrivateKey);

        bytes32 messageId = transferor.transferTokensPayNative(JOVAY_CHAIN_SELECTOR, receiverAddress, token, amount);

        vm.stopBroadcast();

        console.log("");
        console.log("Token transfer initiated!");
        console.log("Message ID:", vm.toString(messageId));
    }
}

/**
 * @title TransferTokenToSepolia
 * @notice Transfer tokens from Jovay Testnet to Sepolia (pay with LINK)
 */
contract TransferTokenToSepolia is Script {
    uint64 constant SEPOLIA_CHAIN_SELECTOR = 16015286601757825753;
    // CCIP-BnM test token on Jovay Testnet
    address constant JOVAY_BNM = 0xB45B9eb94F25683B47e5AFb0f74A05a58be86311;

    function run() external {
        address transferorAddress = vm.envAddress("TOKEN_TRANSFEROR");
        address receiverAddress = vm.envAddress("RECEIVER");
        uint256 amount = vm.envOr("AMOUNT", uint256(2000000000000000));
        address token = vm.envOr("TOKEN", JOVAY_BNM);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        TokenTransferor transferor = TokenTransferor(payable(transferorAddress));

        console.log("Transferring tokens to Ethereum Sepolia...");
        console.log("TokenTransferor:", transferorAddress);
        console.log("Receiver:", receiverAddress);
        console.log("Token:", token);
        console.log("Amount:", amount);

        // Estimate fee
        uint256 fee = transferor.estimateFee(SEPOLIA_CHAIN_SELECTOR, receiverAddress, token, amount, true);
        console.log("Estimated LINK fee:", fee);

        vm.startBroadcast(deployerPrivateKey);

        bytes32 messageId = transferor.transferTokensPayLink(SEPOLIA_CHAIN_SELECTOR, receiverAddress, token, amount);

        vm.stopBroadcast();

        console.log("");
        console.log("Token transfer initiated!");
        console.log("Message ID:", vm.toString(messageId));
        console.log("");
        console.log("Track your transfer at:");
        console.log("https://ccip.chain.link/");
    }
}
