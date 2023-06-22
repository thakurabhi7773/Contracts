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
    uint staker_Count;
    
    struct StakerInfo {
        uint plan_number;
        uint256 staked_Amount;
        uint256 claimed; 
        uint256 startTS; 
        bool active;
    }

    struct Plan {
        string plan_descripation;
        uint256 end_Duration;
        uint256 reward_Percentage;
        bool in_Process;
    }
    
    Plan[] public plans;

    event Claimed(address indexed from, uint256 amount);
    mapping(address => mapping( uint => StakerInfo )) public stakers;
    mapping(address => uint) public User_Count;
    
    IERC20 public tokenContract;

    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
     
 }

  // Function to add a new plan
    function addPlan(string memory _plan_Descripation , uint256 _duration, uint256 intrestPercentage) external onlyOwner {
       plans.push(Plan({
           plan_descripation : _plan_Descripation,
           end_Duration : _duration, 
           reward_Percentage : intrestPercentage,
           in_Process : false }));
    }

    // Function to stake tokens and select a plan
    function Stake(uint256 amount , uint _plan_num ) external  {
       require(_plan_num < plans.length,"invalid plan index");
       require(User_Count[msg.sender] < 5 ,"you can't stake more than 5 times ");

       Plan storage selectedPlan = plans[_plan_num];

       require(!selectedPlan.in_Process ," plan is in process 'please choose another plan'");
      
       tokenContract.transferFrom(msg.sender, address(this), amount);
       totalStakedAmount += amount;
       stakers[msg.sender][User_Count[msg.sender]] = StakerInfo({ 
                plan_number : _plan_num,
                staked_Amount : amount,
                claimed : 0,
                active : true,
                startTS : block.timestamp
        });
       User_Count[msg.sender] ++;
       selectedPlan.in_Process = true;

       
    }

    // Function to claim rewards
    function unStaked(uint _plan_num) external  {
    
        StakerInfo storage staker = stakers[msg.sender][staker_Count];
        Plan storage selectedPlan = plans[_plan_num];

        require(selectedPlan.in_Process == true ,"plan expired");

        uint reward = intrestAmount(msg.sender ,_plan_num);
        tokenContract.transfer(msg.sender, reward);
         staker.claimed += reward;
           uint256 elapsedTime = block.timestamp - staker.startTS;
             if (elapsedTime >= selectedPlan.end_Duration)
        {
            selectedPlan.in_Process = false;
            staker.active = false;
        }
    }


    // Function to calculate the reward for a staker
      function intrestAmount(address stakerAddress , uint _plan_num) public view returns (uint256) {
     
       StakerInfo storage staker = stakers[stakerAddress][staker_Count];
       Plan storage selectedPlan = plans[_plan_num];
       require(selectedPlan.in_Process == true ,"not a valid Plan ");

       uint256 elapsedTime = block.timestamp - staker.startTS;
       uint256 totalAmount = 0; 
       uint endTime = selectedPlan.end_Duration ;

       if (elapsedTime <= endTime)
       {
         totalAmount =  ((staker.staked_Amount * selectedPlan.reward_Percentage * elapsedTime) / (100 *selectedPlan.end_Duration)) - staker.claimed;
       } else
       { 
         totalAmount = ((staker.staked_Amount * selectedPlan.reward_Percentage * endTime) / (100 *selectedPlan.end_Duration)) -staker.claimed + staker.staked_Amount;
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