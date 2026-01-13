// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import { Test } from "forge-std/Test.sol";
import { Sender } from "../src/Sender.sol";
import { Receiver } from "../src/Receiver.sol";
import { TokenTransferor } from "../src/TokenTransferor.sol";

/**
 * @title CCIPTest
 * @notice Basic unit tests for CCIP contracts
 * @dev These tests verify contract deployment and basic functionality
 *      For full integration tests, deploy to testnet and use CCIP
 */
contract CCIPTest is Test {
    // Mock addresses for testing
    address constant MOCK_ROUTER = address(0x1);
    address constant MOCK_LINK = address(0x2);

    Sender public sender;
    Receiver public receiver;
    TokenTransferor public tokenTransferor;

    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = makeAddr("user");

        // Deploy contracts with mock addresses
        sender = new Sender(MOCK_ROUTER, MOCK_LINK);
        receiver = new Receiver(MOCK_ROUTER);
        tokenTransferor = new TokenTransferor(MOCK_ROUTER, MOCK_LINK);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // SENDER TESTS
    // ══════════════════════════════════════════════════════════════════════════

    function test_Sender_Deployment() public view {
        assertEq(sender.getRouter(), MOCK_ROUTER);
        assertEq(sender.getLinkToken(), MOCK_LINK);
        assertEq(sender.getOwner(), owner);
    }

    function test_Sender_OnlyOwnerCanSend() public {
        vm.prank(user);
        vm.expectRevert(Sender.NotOwner.selector);
        sender.sendMessage(1, address(0x3), "test");
    }

    function test_Sender_RejectsZeroReceiver() public {
        vm.expectRevert(Sender.InvalidReceiverAddress.selector);
        sender.sendMessage(1, address(0), "test");
    }

    function test_Sender_CanReceiveETH() public {
        vm.deal(address(this), 1 ether);
        (bool success,) = address(sender).call{ value: 1 ether }("");
        assertTrue(success);
        assertEq(address(sender).balance, 1 ether);
    }

    // ══════════════════════════════════════════════════════════════════════════
    // RECEIVER TESTS
    // ══════════════════════════════════════════════════════════════════════════

    function test_Receiver_Deployment() public view {
        assertEq(receiver.getOwner(), owner);
        assertEq(receiver.allowlistEnabled(), false);
    }

    function test_Receiver_InitialMessageCount() public view {
        assertEq(receiver.getMessageCount(), 0);
    }

    function test_Receiver_OnlyOwnerCanSetAllowlist() public {
        vm.prank(user);
        vm.expectRevert(Receiver.NotOwner.selector);
        receiver.setAllowlistEnabled(true);
    }

    function test_Receiver_OwnerCanSetAllowlist() public {
        receiver.setAllowlistEnabled(true);
        assertTrue(receiver.allowlistEnabled());

        receiver.setAllowlistEnabled(false);
        assertFalse(receiver.allowlistEnabled());
    }

    function test_Receiver_AllowlistSourceChain() public {
        uint64 chainSelector = 123456;

        assertFalse(receiver.allowlistedSourceChains(chainSelector));

        receiver.allowlistSourceChain(chainSelector, true);
        assertTrue(receiver.allowlistedSourceChains(chainSelector));

        receiver.allowlistSourceChain(chainSelector, false);
        assertFalse(receiver.allowlistedSourceChains(chainSelector));
    }

    function test_Receiver_AllowlistSender() public {
        address senderAddr = makeAddr("sender");

        assertFalse(receiver.allowlistedSenders(senderAddr));

        receiver.allowlistSender(senderAddr, true);
        assertTrue(receiver.allowlistedSenders(senderAddr));

        receiver.allowlistSender(senderAddr, false);
        assertFalse(receiver.allowlistedSenders(senderAddr));
    }

    // ══════════════════════════════════════════════════════════════════════════
    // TOKEN TRANSFEROR TESTS
    // ══════════════════════════════════════════════════════════════════════════

    function test_TokenTransferor_Deployment() public view {
        assertEq(tokenTransferor.getRouter(), MOCK_ROUTER);
        assertEq(tokenTransferor.getLinkToken(), MOCK_LINK);
        assertEq(tokenTransferor.getOwner(), owner);
    }

    function test_TokenTransferor_OnlyOwnerCanTransfer() public {
        vm.prank(user);
        vm.expectRevert(TokenTransferor.NotOwner.selector);
        tokenTransferor.transferTokensPayLink(1, address(0x3), address(0x4), 100);
    }

    function test_TokenTransferor_AllowlistDestination() public {
        uint64 chainSelector = 945045181441419236; // Jovay Testnet

        assertFalse(tokenTransferor.allowlistedDestinationChains(chainSelector));

        tokenTransferor.allowlistDestinationChain(chainSelector, true);
        assertTrue(tokenTransferor.allowlistedDestinationChains(chainSelector));

        tokenTransferor.allowlistDestinationChain(chainSelector, false);
        assertFalse(tokenTransferor.allowlistedDestinationChains(chainSelector));
    }

    function test_TokenTransferor_RejectsUnallowlistedDestination() public {
        uint64 chainSelector = 123456; // Not allowlisted

        vm.expectRevert(abi.encodeWithSelector(TokenTransferor.DestinationChainNotAllowed.selector, chainSelector));
        tokenTransferor.transferTokensPayLink(chainSelector, address(0x3), address(0x4), 100);
    }

    function test_TokenTransferor_RejectsZeroReceiver() public {
        uint64 chainSelector = 945045181441419236;
        tokenTransferor.allowlistDestinationChain(chainSelector, true);

        vm.expectRevert(TokenTransferor.InvalidReceiverAddress.selector);
        tokenTransferor.transferTokensPayLink(chainSelector, address(0), address(0x4), 100);
    }

    function test_TokenTransferor_RejectsZeroToken() public {
        uint64 chainSelector = 945045181441419236;
        tokenTransferor.allowlistDestinationChain(chainSelector, true);

        vm.expectRevert(TokenTransferor.InvalidTokenAddress.selector);
        tokenTransferor.transferTokensPayLink(chainSelector, address(0x3), address(0), 100);
    }

    function test_TokenTransferor_RejectsZeroAmount() public {
        uint64 chainSelector = 945045181441419236;
        tokenTransferor.allowlistDestinationChain(chainSelector, true);

        vm.expectRevert(TokenTransferor.InvalidAmount.selector);
        tokenTransferor.transferTokensPayLink(chainSelector, address(0x3), address(0x4), 0);
    }

    function test_TokenTransferor_CanReceiveETH() public {
        vm.deal(address(this), 1 ether);
        (bool success,) = address(tokenTransferor).call{ value: 1 ether }("");
        assertTrue(success);
        assertEq(address(tokenTransferor).balance, 1 ether);
    }
}

/**
 * @title CCIPIntegrationTest
 * @notice Integration tests that can be run on forked networks
 * @dev Run with: forge test --fork-url $SEPOLIA_RPC_URL
 */
contract CCIPIntegrationTest is Test {
    // Real Sepolia addresses
    address constant SEPOLIA_ROUTER = 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59;
    address constant SEPOLIA_LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    function test_Fork_DeploySender() public {
        // This test only runs when forking Sepolia
        if (block.chainid != 11155111) {
            return;
        }

        Sender sender = new Sender(SEPOLIA_ROUTER, SEPOLIA_LINK);

        assertEq(sender.getRouter(), SEPOLIA_ROUTER);
        assertEq(sender.getLinkToken(), SEPOLIA_LINK);
    }
}
