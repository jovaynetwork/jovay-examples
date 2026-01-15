// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleStaking {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    uint public rewardRate = 1e18;
    uint public totalStaked;

    struct User {
        uint amount;          // current stake amount
        uint lastTime;        // last update time
        uint unclaimedRewards; // unclaimed rewards
    }

    mapping(address => User) public users;

    constructor(address _stakingToken) {
        require(_stakingToken != address(0), "Cannot be zero address");
        stakingToken = IERC20(_stakingToken);
    }

    // stake
    function stake(uint amount) external {
        require(amount > 0, "Cannot stake 0");
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        User storage u = users[msg.sender];
        if (u.amount > 0) {
            _update(msg.sender);
        } else {
            u.lastTime = block.timestamp;
        }

        u.amount += amount;
        totalStaked += amount;
    }

    // claim reward
    function claimRewards() external {
        _update(msg.sender);
        uint rewards = users[msg.sender].unclaimedRewards;
        require(rewards > 0, "No rewards to claim");
        users[msg.sender].unclaimedRewards = 0;
        stakingToken.safeTransfer(msg.sender, rewards);
    }

    // withdraw and claim reward
    function withdraw(uint amount) external {
        User storage u = users[msg.sender];
        require(u.amount >= amount, "Not enough staked");
        _update(msg.sender);

        uint rewards = u.unclaimedRewards;
        u.unclaimedRewards = 0;
        u.amount -= amount;
        totalStaked -= amount;

        stakingToken.safeTransfer(msg.sender, amount + rewards);
    }

    function checkRewards(address user) public view returns (uint) {
        User memory u = users[user];
        uint timeDiff = block.timestamp - u.lastTime;
        return u.unclaimedRewards + timeDiff * rewardRate * u.amount / 1e18;
    }

    // update reward
    function _update(address user) internal {
        User storage u = users[user];
        uint timeDiff = block.timestamp - u.lastTime;
        u.unclaimedRewards += timeDiff * rewardRate * u.amount / 1e18;
        u.lastTime = block.timestamp;
    }
}
