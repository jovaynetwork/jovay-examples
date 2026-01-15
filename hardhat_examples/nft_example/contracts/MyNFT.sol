// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    mapping(uint256 => string) private _tokenUris;

    event Minted(address to, uint256 tokenId, string tokenURI);

    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    function mint(address recipient, string calldata _tokenUri) external onlyOwner {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(recipient, tokenId);
        _tokenUris[tokenId] = _tokenUri;
        emit Minted(recipient, tokenId, _tokenUri);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _tokenUris[tokenId];
    }
}
