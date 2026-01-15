const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyToken", function () {
    let MyToken;
    let myToken;
    let owner;
    let addr1;

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();
        MyToken = await ethers.getContractFactory("MyToken");
        initialSupply = ethers.parseUnits("1000", 6);
        myToken = await MyToken.deploy(initialSupply);
        await myToken.waitForDeployment();
    });

    it("Should assign the total supply to the owner", async function () {
        const ownerBalance = await myToken.balanceOf(owner.address);
        expect(await myToken.totalSupply()).to.equal(ownerBalance);
    });

    it("Should transfer tokens between accounts", async function () {
        const sendAmount = ethers.parseUnits("100", 6);
        await myToken.transfer(addr1.address, sendAmount);
        expect(await myToken.balanceOf(addr1.address)).to.equal(sendAmount);
        expect(await myToken.balanceOf(owner.address)).to.equal(
            (await myToken.totalSupply()) - sendAmount
        );
    });

    it("Should have 6 decimals", async function () {
        expect(await myToken.decimals()).to.equal(6);
    });
});
