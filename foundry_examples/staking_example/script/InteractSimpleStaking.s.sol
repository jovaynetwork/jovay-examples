// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Script, console } from "forge-std/Script.sol";
import { MyToken } from "../src/MyToken.sol";
import { SimpleStaking } from "../src/SimpleStaking.sol";

contract InteractStaking is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address stakingAddress = vm.envAddress("STAKING_ADDRESS");

        MyToken token = MyToken(tokenAddress);
        SimpleStaking staking = SimpleStaking(stakingAddress);

        vm.startBroadcast(deployerPrivateKey);

        // Approve and stake
        token.approve(stakingAddress, 10e6);
        staking.stake(10e6);
        console.log("Tokens staked.");

        // Add reward pool to Staking contract
        uint256 rewardPoolAmount = 100_000e6;
        require(token.transfer(address(staking), rewardPoolAmount), "Transfer failed");

        // Simulate time passing (1 hour)
        // Claim rewards after 1 hour
        // staking.claimRewards();

        console.log("Rewards claimed.");

        // Withdraw
        staking.withdraw(10e6);
        console.log("Tokens withdrawn.");

        vm.stopBroadcast();
    }
}
