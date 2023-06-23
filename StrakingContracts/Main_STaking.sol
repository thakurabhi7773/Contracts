// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract is Ownable, ReentrancyGuard, Pausable {
    uint256 maxAmount;
    uint256 minAmount;
    IERC20 public token;

    struct User {
        uint256 amount;
        uint256 claimed;
        uint256 interestRate;
        uint256 startTime;
        uint256 duration;
        bool active;
    }
    mapping(address => mapping(uint256 => User[])) public userMonthtoUserInfo;

    constructor(address _address) {
        maxAmount = 100000 * 10**18;
        minAmount == 100 * 10**18;
        token = IERC20(_address);
    }

    function stake(uint256 amount, uint256 month)
        external
        nonReentrant
        whenNotPaused
        returns (bool)
    {
       
        User[] memory user = new User[](
            userMonthtoUserInfo[msg.sender][month].length
        );
        require(
            user.length < 5,
            "you have reached max limit to stake for this plan" 
        );
        require(amount >= minAmount, "you have to spend more");
        require(amount <= maxAmount, "you have to spend less");
        token.transferFrom(msg.sender, address(this), amount); 

        uint256 interest;

        if (month == 3) {
            interest = 22;
        } else if (month == 6) {
            interest = 45;
        } else if (month == 12) {
            interest = 100;
        } else {
            revert("please select a valid plan");
        }
        User memory users = User(
            amount,
            0,
            interest,
            block.timestamp,
            month,
            true
        );
        userMonthtoUserInfo[msg.sender][month].push(users);
        return true;
    }

    function unstake(uint256 month, uint256 id) external nonReentrant returns (bool) {
        uint256 secondInMonth = 60;
        User storage user = userMonthtoUserInfo[msg.sender][month][id];
        uint256 endTimeStamp = (user.duration * secondInMonth) + user.startTime;
        require(block.timestamp > endTimeStamp, "plan is still active");
        require(user.active == true, "you have already unstaked");
        uint256 reward = calculateReward(user.amount, user.interestRate, month);
        token.transfer(msg.sender, user.amount + reward);
        user.claimed = reward;
        user.active = false;
        return true;
    }

    function calculateReward(
        uint256 amount,
        uint256 interestRate,
        uint256 month
    ) internal pure returns (uint256) {
        uint256 reward = (amount * interestRate * month) / (1000 * 12);
        return reward;
    }

    function updateMinAmount(uint _minAmount) external onlyOwner {
        minAmount=_minAmount;
    }

    function updateMaxAmount(uint _maxAmount) external onlyOwner {
        maxAmount=_maxAmount;
    }

    function withdraw() external onlyOwner {
        uint256 contractBalance = token.balanceOf(address(this));
        require(
            contractBalance > 0,
            "Contract does not have any balance to withdraw"
        );
        token.transfer(msg.sender, contractBalance); 
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}