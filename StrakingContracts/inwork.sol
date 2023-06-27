// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract StakingContract is ERC20 {

   address public owner;
   uint256 public totalStakedAmount;
   uint8 constant _decimals = 18;
   uint256 constant _totalSupply = 100 * (10**6) * 10**_decimals;
   
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
   

    mapping(address =>mapping( uint => Stake )) public stakerToStakes;
    mapping (address => uint) public staker_To_Count;

    uint256 public constant MIN_STAKING_DURATION = 300; // 300 seconds
    uint256 public constant MAX_STAKING_DURATION = 1200; // 1200 seconds
    uint256[] public interestRates = [5, 10, 15, 20];

    constructor() ERC20("Abhishek", "ABHI") {  
         owner = msg.sender;
         _mint(owner, _totalSupply);
     }

    function stake(uint256 amount, uint256 duration) external  {
        require(msg.sender != owner, "Owner Can't stake");
        require(duration >= MIN_STAKING_DURATION  &&  duration <= MAX_STAKING_DURATION, "Invalid staking duration");
        require(amount > 0, "Amount should be greater than 0");

        ERC20.transferFrom(msg.sender, address(this), amount);
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
        require(stakess.inProcess == true ," only valid staker have rights ");
        require(!stakess.isClaimed, "Stake already claimed");
        require(block.timestamp >= stakess.endTimestamp, "Stake duration not completed");

        uint256 reward = (stakess.amount * stakess.interestRate * stakess.duration) / (100 * MIN_STAKING_DURATION) + stakess.amount;

        ERC20.transfer(msg.sender, reward);
        stakess.clamimedAmount=reward;
        stakess.isClaimed = true;
        stakess.inProcess = false;
    }
    
    function withdraw() external  {
        require(msg.sender == owner,"only owner");
        uint256 contractBalance = ERC20.balanceOf(address(this));
        require(
            contractBalance > 0,
            "Contract does not have any balance to withdraw"
        );
        ERC20.transfer(msg.sender, contractBalance); 
    }


    
}
