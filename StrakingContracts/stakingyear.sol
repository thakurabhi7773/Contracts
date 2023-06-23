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
    uint256 public staker_Count;
    uint256 public constant MIN_STAKING_DURATION = 50;   //31536000;   // 1 year = 365 Days (365 * 24 * 60 * 60)
    uint256 public constant MEX_STAKING_DURATION = 200;   //12614400;  // 4 year = 4 * 365 days (1460 * 24 * 60 * 60)

    
    struct stakerInfo {
        uint256 balance;
        uint256 claimed; 
        uint256 startTS;
        bool active;
    }
     mapping(address =>mapping(uint => stakerInfo)) public stakers;
     mapping (address => uint) public staker_To_Count;

     IERC20 public tokenContract;
     
    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
 }
   // Function to stake tokens and select a plan
    function stake(uint256 amount) external {
        require(amount > 0, "Amount should be greater than 0");
        require(staker_To_Count[msg.sender] < 5 ,"You can't stake more than 5 times ");
        tokenContract.transferFrom(msg.sender, address(this), amount);
        totalStakedAmount += amount;

        stakers[msg.sender][staker_To_Count[msg.sender]] = stakerInfo({                
                balance: amount,
                claimed:0,
                active:true,
                startTS:block.timestamp
        });
                staker_Count++;
                staker_To_Count[msg.sender]++;

    }
    
    // Function to claim rewards
    function unStaked(uint stake_Index) external {
        stakerInfo memory staker = stakers[msg.sender][stake_Index];
        require(staker.balance > 0);
        require(staker.active == true,"allready unstake");
        require(block.timestamp >= staker.startTS + MIN_STAKING_DURATION,"Staking period not reached" );
        uint reward = intrestAmount(msg.sender,stake_Index );
        tokenContract.transfer(msg.sender, reward);
        stakers[msg.sender][stake_Index].claimed += reward;

    }

    
    //    uint reward = 0;
    //    uint interestRate;

//         if (block.timestamp <= staker.startTS + MIN_STAKING_DURATION){
//             interestRate = 5 ;
//             reward =  ((staker.balance * interestRate ) / (100)) - staker.claimed;
//              tokenContract.transfer(msg.sender, reward);
//         }else if (block.timestamp <= staker.startTS + (2 * MIN_STAKING_DURATION)){
//             interestRate = 15 ;
//             reward =  ((staker.balance * interestRate ) / (100)) - staker.claimed;
//              tokenContract.transfer(msg.sender, reward);
//         }else if (block.timestamp <= staker.startTS + (3 * MIN_STAKING_DURATION)){
//             interestRate = 30 ;
//             reward =  ((staker.balance * interestRate ) / (100)) - staker.claimed;
//              tokenContract.transfer(msg.sender, reward);
//         }
//         else if (block.timestamp <= staker.startTS + (4 * MIN_STAKING_DURATION)){
//             interestRate = 50 ;
//             reward =  ((staker.balance * interestRate ) / (100)) - staker.claimed ;
//              tokenContract.transfer(msg.sender, reward);
//         }else {
//               interestRate = 50 ;
//             reward =  ((staker.balance * interestRate ) / (100)) - staker.claimed + staker.balance;
//              tokenContract.transfer(msg.sender, reward);

//         }
//         return reward ;
//         }
// }

    // Function to calculate the reward for a staker
    function intrestAmount(address stakerAddress , uint stake_Index ) public view returns (uint256) {
       stakerInfo memory staker = stakers[stakerAddress][stake_Index];
       uint256 elapsedTime = block.timestamp - staker.startTS;
       uint256 totalAmount = 0; 
        uint interest_Rate;
      if (elapsedTime <= MIN_STAKING_DURATION){
         interest_Rate = 5;
          totalAmount =  ((staker.balance * interest_Rate ) / (100)) - staker.claimed;
        //  totalAmount =  ((staker.balance * interest_Rate * elapsedTime ) / (100 * MIN_STAKING_DURATION)) - staker.claimed;
       }
        else if(elapsedTime  <= 2 * MIN_STAKING_DURATION){
          interest_Rate = 15;
           totalAmount =  ((staker.balance * interest_Rate ) / (100)) - staker.claimed;
        //   totalAmount =  ((staker.balance * interest_Rate * elapsedTime ) / (100 * 2 * MIN_STAKING_DURATION)) - staker.claimed;
       }
        else if (elapsedTime  <= 3 * MIN_STAKING_DURATION){
          interest_Rate = 30;
           totalAmount =  ((staker.balance * interest_Rate ) / (100)) - staker.claimed;
        //   totalAmount =  ((staker.balance * interest_Rate * elapsedTime) / (100 * 3 * MIN_STAKING_DURATION)) - staker.claimed;
       }
       else if(elapsedTime  <= 4 * MIN_STAKING_DURATION){
           interest_Rate = 50;
            totalAmount =  ((staker.balance * interest_Rate ) / (100)) - staker.claimed;
        //   totalAmount =  ((staker.balance * interest_Rate * elapsedTime) / (100 * 4 * MIN_STAKING_DURATION)) - staker.claimed;
       }
       else  { 
                 uint totalInterestRate = 50 ;  // interest      5 = (interets of 1 year) + 10 = (interets of 2 year) + 15 (interets of 3 year) + 20 (interets of 4 year) ;
        totalAmount = ((staker.balance * totalInterestRate * MIN_STAKING_DURATION) / (100 * MEX_STAKING_DURATION)) - staker.claimed + staker.balance;
      }
      
        return totalAmount;
    }
}


    // function time(address add ,uint stake_Index ) public view returns(uint){
    //      stakerInfo memory staker = stakers[add][stake_Index];
    //    uint256 elapsedTime = block.timestamp - staker.startTS;
    //    return elapsedTime;

    // } 

   


