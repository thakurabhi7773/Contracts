// SPDX-License-Identifier: MIT
  pragma solidity ^0.8.0;

  
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract is Ownable{

    uint256 public totalStakedAmount;
   

    struct StakerInfo {
        uint256 balance;
        uint256 duration;
        uint256 interestRate;
        uint256 claimed; 
        uint256 startTS;
        uint256 endTS;
        bool isActive;
 }
    StakerInfo[] public stakerInfo;
    
     uint256 public constant MIN_STAKING_DURATION = 300;   //31536000;   // 1 year = 365 Days (365 * 24 * 60 * 60)
     uint256 public constant MEX_STAKING_DURATION = 1200;   //12614400;  // 4 year = 4 * 365 days (1460 * 24 * 60 * 60)
     uint256[] public interestRates = [5, 10, 15, 20];  

     mapping (address => uint) public staker_To_Count;

     IERC20 public tokenContract;
     
    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
 }

   // Function to stake tokens and select a plan
    function stake(uint256 amount , uint256 _duration ) external  {

        require(_duration >= MIN_STAKING_DURATION && _duration <= MEX_STAKING_DURATION, "Invalid staking duration");
        require(amount > 0, "Amount should be greater than 0");
        require( staker_To_Count[msg.sender] < 5 , "you can't stake more than 5 times");

        tokenContract.transferFrom(msg.sender, address(this), amount);
        totalStakedAmount += amount;
        uint256 interestRate = interestRates[(_duration / 300) - 1];
        uint256 startTimestamp = block.timestamp;
        uint256 endTimestamp = startTimestamp + _duration;

        stakerInfo.push(StakerInfo({                
                balance: amount,
                duration: _duration,
                interestRate: interestRate,
                claimed: 0,
                startTS: startTimestamp,
                endTS: endTimestamp,
                isActive : true
             }));
         
        staker_To_Count[msg.sender]++;
    }
    
    // Function to claim rewards
    function unStaked(uint stake_Index) external {

        StakerInfo storage selectedStaker = stakerInfo[stake_Index];
        require(stakerInfo[stake_Index].balance > 0);
        require(block.timestamp >= selectedStaker.startTS + MIN_STAKING_DURATION,"Staking period not reached" );

        uint reward = intrestAmount(stake_Index );
        tokenContract.transfer(msg.sender, reward);
        selectedStaker.claimed += reward;
         
        if (selectedStaker.startTS >= selectedStaker.endTS){
           selectedStaker.isActive = false;
        }

    }
    // Function to calculate the reward for a staker
    function intrestAmount( uint stake_Index ) public view returns (uint256) {

       StakerInfo storage selectedStaker =stakerInfo[stake_Index];
       uint256 elapsedTime = block.timestamp - selectedStaker.startTS;
       uint256 totalAmount = 0; 
      
      if (elapsedTime <= selectedStaker.duration ){
         totalAmount =  ((selectedStaker.balance * selectedStaker.interestRate *selectedStaker.duration ) / (100 * MIN_STAKING_DURATION)) - selectedStaker.claimed ;
      }else 
      {
         totalAmount =  ((selectedStaker.balance * selectedStaker.interestRate * elapsedTime ) / (100 * MIN_STAKING_DURATION)) - selectedStaker.claimed + selectedStaker.balance;
      }
         return totalAmount;
    }

}
