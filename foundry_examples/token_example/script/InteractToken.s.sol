// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { MyToken } from "../src/MyToken.sol";

contract InteractToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyToken token = MyToken(vm.envAddress("TOKEN_ADDRESS"));

        // Check balance
        uint256 balance = token.balanceOf(msg.sender);
        console.log("Balance:", balance);

        // Transfer tokens
        address recipient = vm.envAddress("RECIPIENT_ADDRESS");
        uint256 amount = vm.envUint("AMOUNT");
        require(token.transfer(recipient, amount), "Transfer failed");
        console.log("Tokens transferred");

        vm.stopBroadcast();
    }
}
