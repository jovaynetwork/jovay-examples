// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { MyToken } from "../src/MyToken.sol";
import { SimpleStaking } from "../src/SimpleStaking.sol";

contract SimpleStakingTest is Test {
    MyToken public token;
    SimpleStaking public staking;
    address owner = address(0x1);
    address alice = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new MyToken(10_000_000e6); // deploy empty
        require(token.transfer(alice, 1000e6), "Transfer failed");
        staking = new SimpleStaking(address(token));
        require(token.transfer(address(staking), 1000_000e6), "Transfer failed");
        vm.stopPrank();
    }

    function testStakeAndGetRewards() public {
        uint256 amount = 100e6;

        // Mint and approve tokens for Alice
        vm.startPrank(alice);
        token.approve(address(staking), amount);
        staking.stake(amount);

        // Simulate time passing (1 hour)
        vm.warp(block.timestamp + 3600);

        // Check rewards
        uint256 rewards = staking.checkRewards(alice);
        assertGt(rewards, 0);

        // Claim rewards
        staking.claimRewards();
        assertEq(staking.checkRewards(alice), 0);
        vm.stopPrank();
    }

    function testWithdraw() public {
        uint256 amount = 100e6;
        vm.startPrank(alice);
        token.approve(address(staking), amount);
        staking.stake(amount);

        // Withdraw
        staking.withdraw(amount);
        assertEq(token.balanceOf(alice), 1_000e6);
        vm.stopPrank();
    }
}
