const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("SimpleStaking", function () {
    let MyToken;
    let myToken;
    let SimpleStaking;
    let simpleStaking;
    let owner, user1, user2;
    const initialSupply = ethers.parseUnits("1000000", 6);
    const stakeAmount = ethers.parseUnits("1000", 6);

    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();
        // Deploy Token
        MyToken = await ethers.getContractFactory("MyToken");
        myToken = await MyToken.deploy(initialSupply);
        await myToken.waitForDeployment();
        // Deploy Staking
        SimpleStaking = await ethers.getContractFactory("SimpleStaking");
        simpleStaking = await SimpleStaking.deploy(await myToken.getAddress());
        await simpleStaking.waitForDeployment();
        // Mint some tokens to users
        await myToken.transfer(user1.address, ethers.parseUnits("100000", 6)); // give 100k MTK
        await myToken.transfer(user2.address, ethers.parseUnits("100000", 6));
        // Approve large amounts for staking contract
        await myToken.approve(await simpleStaking.getAddress(), ethers.MaxUint256);
        await myToken.connect(user1).approve(await simpleStaking.getAddress(), ethers.MaxUint256);
        await myToken.connect(user2).approve(await simpleStaking.getAddress(), ethers.MaxUint256);
        await myToken.transfer(await simpleStaking.getAddress(), ethers.parseUnits("100000", 6));
    });

    it("Should stake tokens and update state", async function () {
        await simpleStaking.stake(stakeAmount);
        const user = await simpleStaking.users(owner.address);
        expect(user.amount).to.equal(stakeAmount);
        expect(await simpleStaking.totalStaked()).to.equal(stakeAmount);
    });

    it("Should calculate rewards correctly", async function () {
        await simpleStaking.stake(stakeAmount);
        await time.increase(3600); // increase time by 1 hour
        const rewards = await simpleStaking.checkRewards(owner.address);
        const expectedRewards =
            (BigInt(3600) * await simpleStaking.rewardRate() * BigInt(stakeAmount)) / BigInt(1e18);
        expect(rewards).to.equal(expectedRewards);
    });

    it("Should allow non-owner to stake", async function () {
        await simpleStaking.connect(user1).stake(stakeAmount);
        const user = await simpleStaking.users(user1.address);
        expect(user.amount).to.equal(stakeAmount);
    });
});
