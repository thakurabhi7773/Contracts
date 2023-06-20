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
    uint256 private planCount;
    
  
    struct stakerInfo {
        uint256 staked_Amount;
        uint256 claimed; 
        uint256 startTS; 
        bool active;
    }

    struct plan {
        address planer;
        uint256 duration;
        uint256 rewardPercentage;
        bool inProcess;
    }
  

    event Claimed(address indexed from, uint256 amount);
    mapping(address => mapping (uint => stakerInfo)) public stakers;
    mapping (uint => plan) public Plans;
    mapping(address => uint) public User_Count;
    
    IERC20 public tokenContract;
   

    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
     
 }

  // Function to add a new plan
    function addPlan(uint256 _duration, uint256 intrestPercentage) external  {
          require(planCount < 5 ,"Keep Waiting");
          Plans[planCount]=plan({
           planer: msg.sender,
           duration: _duration,
           rewardPercentage: intrestPercentage,
           inProcess: true
       });
          
           planCount++;
 }

    // Function to stake tokens and select a plan
    function Stake(uint256 amount) external  {
       plan storage selectedPlan = Plans[planCount];
       require(User_Count[msg.sender] < 5 ,"You can't stake more than 5 times ");
       require( selectedPlan.inProcess == false ," plan is in process now you have to choose another plan");
      
       tokenContract.transferFrom(msg.sender, address(this), amount);
       totalStakedAmount += amount;
       stakers[msg.sender][User_Count[msg.sender]] = stakerInfo({                
                staked_Amount: amount,
                claimed: 0,
                active: true,
                startTS: block.timestamp
        });
         User_Count[msg.sender] ++;
         selectedPlan.inProcess = true;

       
    }

    // Function to claim rewards
    function unStaked(uint planIndex) external  {
     
        stakerInfo storage staker = stakers[msg.sender][planIndex];
        plan storage selectedPlan = Plans[planIndex];

        require(selectedPlan.inProcess = true ,"plan expired");
        uint reward = intrestAmount(msg.sender ,planIndex);
        stakers[msg.sender][planIndex].startTS = block.timestamp;
        tokenContract.transfer(msg.sender, reward);
        stakers[msg.sender][planIndex].claimed += reward;
        if ( staker.staked_Amount == 0 ){
            selectedPlan.inProcess = false;
        }

    }


    // Function to calculate the reward for a staker
      function intrestAmount(address stakerAddress , uint plan_Index) public view returns (uint256) {
       stakerInfo storage staker = stakers[stakerAddress][plan_Index];
       plan storage selectedPlan = Plans[plan_Index];
       uint256 elapsedTime = block.timestamp - staker.startTS;
       uint256 totalAmount = 0; 
       uint endTime =   Plans[plan_Index].duration ;
      if (elapsedTime < endTime)
       {
         totalAmount =  ((staker.staked_Amount * selectedPlan.rewardPercentage * elapsedTime) / (100 *selectedPlan.duration)) - staker.claimed;
       }
     else { 
         totalAmount = ((staker.staked_Amount * selectedPlan.rewardPercentage * endTime) / (100 *selectedPlan.duration)) -staker.claimed + staker.staked_Amount;
     }
      return totalAmount;
    
 }

}


















//     function intrestAmount(address stakerAddress , uint planIndex ) public view returns (uint256) {
//        stakerInfo storage staker = stakers[stakerAddress][planIndex];
//        plan storage selectedPlan = Plans[planIndex];
//        uint256 elapsedTime = block.timestamp - staker.startTS;
//        uint Amount = 0;

//        if(block.timestamp < (selectedPlan.duration + staker.startTS) - elapsedTime) {
//          Amount =  ((staker.staked_Amount * selectedPlan.rewardPercentage * elapsedTime) / (100 *selectedPlan.duration));
//        }
//        else { 
//          uint endTime =  selectedPlan.duration ;
//          Amount = ((staker.staked_Amount * selectedPlan.rewardPercentage * endTime) / (100 *selectedPlan.duration)) - staker.claimed + staker.staked_Amount ;
//        }

//        return Amount;
     
//  }