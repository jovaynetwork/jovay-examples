// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { MyToken } from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner = address(0x1);
    address public alice = address(0x2);

    function setUp() public {
        vm.prank(owner);
        token = new MyToken(1_000_000e6); // initial supply with 6 decimals
    }

    // Test name and symbol
    function testNameAndSymbol() public view {
        assertEq(token.name(), "MyToken");
        assertEq(token.symbol(), "MTK");
    }

    // Test initial supply
    function testInitialSupply() public view {
        assertEq(token.balanceOf(owner), 1_000_000e6);
    }

    // Test decimals are 6
    function testDecimals() public view {
        assertEq(token.decimals(), 6);
    }

    // Test token transfer
    function testTransfer() public {
        vm.startPrank(owner);
        uint256 sendAmount = 100e6; // 100 tokens
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 aliceBalanceBefore = token.balanceOf(alice);

        require(token.transfer(alice, sendAmount), "Transfer failed");

        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 aliceBalanceAfter = token.balanceOf(alice);

        assertEq(ownerBalanceAfter, ownerBalanceBefore - sendAmount);
        assertEq(aliceBalanceAfter, aliceBalanceBefore + sendAmount);
        vm.stopPrank();
    }

    // Test transfer reverts when balance is insufficient
    function testTransferRevertsWhenInsufficientBalance() public {
        vm.expectRevert();
        token.transfer(alice, 1_000_001e6); // Attempt to send more than balance
    }
}
