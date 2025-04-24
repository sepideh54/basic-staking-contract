// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract BasicStaking {
    struct Staker {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Staker) public stakes;

    event Staked(uint256 amount, address indexed staker);
    event Withdrawn(uint256 totalAmount, uint256 reward, address indexed staker);

    function stake() external payable {
        require(msg.value > 0, "Stake must be greater than zero.");

        Staker storage user = stakes[msg.sender];
        user.amount += msg.value;
        user.timestamp = block.timestamp;

        emit Staked(msg.value, msg.sender);
    }

    function calculateReward(address _staker) public view returns (uint256) {
        Staker memory user = stakes[_staker];
        uint256 stakingTimeInDays = (block.timestamp - user.timestamp) / 1 days;
        uint256 rewardRatePerDay = 10; // 10% per day for simplicity
        uint256 reward = (user.amount * rewardRatePerDay * stakingTimeInDays) / 100;
        return reward;
    }

    function withdraw() external {
        Staker storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No active stake");

        uint256 reward = calculateReward(msg.sender);
        uint256 totalAmount = userStake.amount + reward;

        stakes[msg.sender] = Staker(0, 0); // Reset

        payable(msg.sender).transfer(totalAmount);
        emit Withdrawn(totalAmount, reward, msg.sender);
    }

    receive() external payable {}
    fallback() external payable {}
}
