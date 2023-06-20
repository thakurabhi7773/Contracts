// SPDX-License-Identifier: MIT
  pragma solidity ^0.8.0;

  
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract is Ownable {

    uint256 public totalStakedAmount;

    struct stakerInfo {
        uint256 balance;
        uint256 duration;
        uint256 interestRate;
        uint256 claimed; 
        uint256 startTS;
        uint256 endTS;
        bool isActive;
    }
    
     uint256 public constant MIN_STAKING_DURATION = 50;   //31536000;   // 1 year = 365 Days (365 * 24 * 60 * 60)
     uint256 public constant MEX_STAKING_DURATION = 200;   //12614400;  // 4 year = 4 * 365 days (1460 * 24 * 60 * 60)
     uint256[] public interestRates = [5, 10, 15, 20];  

     mapping(address =>mapping(uint => stakerInfo)) public stakers;
     mapping (address => uint) public staker_To_Count;

     IERC20 public tokenContract;
     
    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
 }

   // Function to stake tokens and select a plan
    function stake(uint256 amount , uint256 _duration ) external  {

        require(_duration >= MIN_STAKING_DURATION && _duration <= MEX_STAKING_DURATION, "Invalid staking duration");
        require(amount > 0, "Amount should be greater than 0");
        require(staker_To_Count[msg.sender] < 5 ,"You can't stake more than 5 times ");

        tokenContract.transferFrom(msg.sender, address(this), amount);
        totalStakedAmount += amount;
        uint256 interestRate = interestRates[(_duration / 300) - 1];
        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = startTimestamp + _duration;

        stakers[msg.sender][staker_To_Count[msg.sender]] = stakerInfo({                
                balance: amount,
                duration: _duration,
                interestRate: interestRate,
                claimed: 0,
                startTS: startTimestamp,
                endTS: endTimestamp,
                isActive : true
        });
        staker_To_Count[msg.sender]++;

    }
    
    // Function to claim rewards
    function unStaked(uint stake_Index) external {

        stakerInfo storage staker = stakers[msg.sender][stake_Index];
        require(staker.balance > 0);
        require(block.timestamp >= staker.startTS + MIN_STAKING_DURATION,"Staking period not reached" );

        uint reward = intrestAmount(msg.sender,stake_Index );
        tokenContract.transfer(msg.sender, reward);
        stakers[msg.sender][stake_Index].claimed += reward;

    }


    // Function to calculate the reward for a staker
    function intrestAmount(address stakerAddress , uint stake_Index ) public view returns (uint256) {

       stakerInfo storage staker = stakers[stakerAddress][stake_Index];
       uint256 elapsedTime = block.timestamp - staker.startTS;
       uint256 totalAmount = 0; 
      
      if (elapsedTime <= staker.duration ){
         totalAmount =  ((staker.balance * staker.interestRate *staker.duration ) / (100 * MIN_STAKING_DURATION)) - staker.claimed ;
         }
         else {
         totalAmount =  ((staker.balance * staker.interestRate * elapsedTime ) / (100 * MIN_STAKING_DURATION)) - staker.claimed + staker.balance;
         }
         return totalAmount;
    }

     function getBalance (address _add , uint stake_Index) public view returns(uint){
          stakerInfo storage staker = stakers[_add][stake_Index];
          uint bal = staker.balance ;
          return bal ;


     }



}




      //  }
      //   else if(elapsedTime  < 2 * MIN_STAKING_DURATION){
      //     interest_Rate = 15;
          
      //      totalAmount =  ((staker.balance * interest_Rate * elapsedTime ) / (100 * 2 * MIN_STAKING_DURATION)) - staker.claimed;
      //  }
      //   else if (elapsedTime  < 3 * MIN_STAKING_DURATION){
      //     interest_Rate = 30;
          
      //      totalAmount =  ((staker.balance * interest_Rate * elapsedTime) / (100 * 3 * MIN_STAKING_DURATION)) - staker.claimed;
      //  }
      //  else if(elapsedTime  < 4 * MIN_STAKING_DURATION){
      //      interest_Rate = 50;
          
      //     totalAmount =  ((staker.balance * interest_Rate * elapsedTime) / (100 * 4  * MIN_STAKING_DURATION)) - staker.claimed;
      //  }
      //  else  { 
      //            uint totalInterestRate = 50 ;  // interest      5 = (interets of 1 year) + 10 = (interets of 2 year) + 15 (interets of 3 year) + 20 (interets of 4 year) ;
      //   totalAmount = ((staker.balance * totalInterestRate * MIN_STAKING_DURATION) / (100 * MIN_STAKING_DURATION)) - staker.claimed + staker.balance;
      // }
      
    //     return totalAmount;
    // }



