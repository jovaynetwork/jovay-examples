const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyNFT", function () {
    let MyNFT;
    let myNFT;
    let owner;
    let addr1;
    let tokenURI = "https://example.com/token/1";

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();
        MyNFT = await ethers.getContractFactory("MyNFT");
        myNFT = await MyNFT.deploy();
        await myNFT.waitForDeployment();
    });

    it("Should mint an NFT and set tokenURI correctly", async function () {
        const tx = await myNFT.mint(addr1.address, tokenURI);
        await tx.wait();
        expect(await myNFT.ownerOf(0)).to.equal(addr1.address);
        expect(await myNFT.tokenURI(0)).to.equal(tokenURI);
    });

    it("Should only allow owner to mint", async function () {
        await expect(
            myNFT.connect(addr1).mint(addr1.address, tokenURI)
        ).to.be.revertedWithCustomError(myNFT, 'OwnableUnauthorizedAccount');
    });

    it("Should increment tokenId on each mint", async function () {
        await myNFT.mint(addr1.address, tokenURI);
        await myNFT.mint(addr1.address, tokenURI);
        expect(await myNFT.ownerOf(0)).to.equal(addr1.address);
        expect(await myNFT.ownerOf(1)).to.equal(addr1.address);
        expect(await myNFT.nextTokenId()).to.equal(2);
    });
});
