// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract is Ownable {
 

    struct Stake {
        uint256 amount;
        uint256 duration;
        uint256 interestRate;
        uint256 startTimestamp;
        uint clamimedAmount;
        uint256 endTimestamp;
        bool isClaimed;
        bool inProcess;
    }

    IERC20 public tokenContract;
    uint256 public totalStakedAmount;
    mapping(address =>mapping( uint => Stake )) public stakerToStakes;
    mapping (address => uint) public staker_To_Count;


    uint256 public constant MIN_STAKING_DURATION = 300; // 300 seconds
    uint256 public constant MAX_STAKING_DURATION = 1200; // 1200 seconds
    uint256[] public interestRates = [5, 10, 15, 20];

    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
    }

    function stake(uint256 amount, uint256 duration) external {
        require(duration >= MIN_STAKING_DURATION  &&  duration <= MAX_STAKING_DURATION, "Invalid staking duration");
        require(amount > 0, "Amount should be greater than 0");

        tokenContract.transferFrom(msg.sender, address(this), amount);
        totalStakedAmount += amount;

        uint256 interestRate = interestRates[(duration / 300) - 1];
        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = startTimestamp + duration;

        stakerToStakes[msg.sender][staker_To_Count[msg.sender]] = Stake ({
          amount: amount,
          duration: duration,
          interestRate: interestRate,
          startTimestamp: startTimestamp,
          clamimedAmount: 0,
          endTimestamp: endTimestamp,
          isClaimed: false,
          inProcess: true
        });

          staker_To_Count[msg.sender]++;
    }

    function unStake(uint256 index) external  {
        Stake storage stakess = stakerToStakes[msg.sender][index];
        require(!stakess.isClaimed, "Stake already claimed");
        require(block.timestamp >= stakess.endTimestamp, "Stake duration not completed");

        uint256 reward = (stakess.amount * stakess.interestRate * stakess.duration) / (100 * MIN_STAKING_DURATION) + stakess.amount;

        tokenContract.transfer(msg.sender, reward);
        stakess.clamimedAmount=reward;
        stakess.isClaimed = true;
        stakess.inProcess = false;
    }
    
     function getBalance (address _add , uint stake_Index) public view returns(uint){
          Stake storage staker = stakerToStakes[_add][stake_Index];
          uint bal = staker.amount ;
          return bal ;


     }


    
}