// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { SimpleStaking } from "../src/SimpleStaking.sol";

contract DeploySimpleStaking is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        SimpleStaking staking = new SimpleStaking(tokenAddress);
        console.log("Staking contract deployed at:", address(staking));

        vm.stopBroadcast();
    }
}
