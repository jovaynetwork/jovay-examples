// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { Test } from "forge-std/Test.sol";
import { MyNFT, Ownable } from "../src/MyNFT.sol";

contract MyNFTTest is Test {
    MyNFT public nft;
    address public owner = address(0x1);
    address public alice = address(0x2);
    string public constant TEST_URI = "ipfs://test-uri";

    function setUp() public {
        vm.prank(owner);
        nft = new MyNFT();
    }

    // Test name and symbol
    function testNameAndSymbol() public view {
        assertEq(nft.name(), "MyNFT");
        assertEq(nft.symbol(), "MNFT");
    }

    // Test initial state
    function testInitialState() public view {
        assertEq(nft.nextTokenId(), 0);
    }

    // Test minting assigns correct owner and tokenId
    function testMintAssignsToken() public {
        vm.startPrank(owner);
        uint256 tokenId = nft.nextTokenId();
        nft.mint(alice, TEST_URI);

        assertEq(nft.ownerOf(tokenId), alice);
        assertEq(nft.tokenURI(tokenId), TEST_URI);
        assertEq(nft.nextTokenId(), tokenId + 1);
        assertTrue(nft.balanceOf(alice) > 0);
        vm.stopPrank();
    }

    // Test only owner can mint
    function testOnlyOwnerCanMint() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        vm.prank(alice);
        nft.mint(alice, TEST_URI);
    }

    // Test token exists after mint
    function testTokenExistsAfterMint() public {
        vm.startPrank(owner);
        uint256 tokenId = nft.nextTokenId();
        nft.mint(alice, TEST_URI);
        assertEq(nft.ownerOf(tokenId), alice);
        vm.stopPrank();
    }

    // Test tokenURI reverts if queried for non-existent token
    function testTokenURIForNonExistentTokenFails() public {
        bytes4 erc721NonexistentTokenSelector = bytes4(keccak256("ERC721NonexistentToken(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(erc721NonexistentTokenSelector, 0));
        nft.tokenURI(0); // tokenId 0 does not exist yet
    }

    // Test event is emitted on mint
    function testMintEmitsEvent() public {
        vm.startPrank(owner);
        uint256 tokenId = nft.nextTokenId();
        vm.expectEmit(true, true, true, true);
        emit MyNFT.Minted(alice, tokenId, TEST_URI);
        nft.mint(alice, TEST_URI);
        vm.stopPrank();
    }
}
