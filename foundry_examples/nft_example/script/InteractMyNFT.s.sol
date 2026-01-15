// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { MyNFT } from "../src/MyNFT.sol";

contract InteractNFT is Script {
    function run() external {
        // Load private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Replace with your deployed contract address
        address nftAddress = vm.envAddress("NFT_ADDRESS");
        MyNFT nft = MyNFT(nftAddress);

        // Mint an NFT to yourself (or another recipient)
        address recipient = vm.envAddress("RECIPIENT_ADDRESS");
        string memory tokenURI = vm.envString("TOKEN_URI");

        nft.mint(recipient, tokenURI);
        console.log("NFT minted to:", recipient);
        console.logString(tokenURI);

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
