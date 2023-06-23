// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract is Ownable {

    uint public totalStakedAmount;
    uint staker_Count;
    
    struct StakerInfo {
        uint plan_number;
        uint staked_Amount;
        uint claimed; 
        uint startTS; 
        bool active;
    }

    struct Plan {
        string plan_descripation;
        uint end_Duration;
        uint reward_Percentage;
        bool in_Process;
        uint stake_Count;
    }
    
    Plan[] public plans;

    event Claimed(address indexed from, uint amount);
    mapping(address => mapping( uint => StakerInfo )) public stakers;
    mapping(address => uint) public User_Count;
    
    IERC20 public tokenContract;

    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
     
 }
// Function to add a new plan
    function addPlan(string memory _plan_Descripation , uint _duration, uint intrestPercentage) external onlyOwner {
       plans.push(Plan({
           plan_descripation : _plan_Descripation,
           end_Duration : _duration, 
           reward_Percentage : intrestPercentage,
           in_Process : false,
           stake_Count : 0  }));
    }

    // Function to stake tokens and select a plan
    function Stake(uint amount , uint _plan_ID ) external  {
       require(_plan_ID < plans.length,"invalid plan index");
      // require(User_Count[msg.sender] < 15 ,"you can't stake more than 5 times ");
       Plan storage selectedPlan = plans[_plan_ID];
       require(selectedPlan.stake_Count < 5 , "you can't stake more than 5 times in a single plan");
      //require(!selectedPlan.in_Process ," plan is in process 'please choose another plan'");
      
       tokenContract.transferFrom(msg.sender, address(this), amount);
       totalStakedAmount += amount;
       stakers[msg.sender][User_Count[msg.sender]] = StakerInfo({ 
                plan_number : _plan_ID,
                staked_Amount : amount,
                claimed : 0,
                active : true,
                startTS : block.timestamp
        });
       User_Count[msg.sender] ++;
       selectedPlan.in_Process = true;
       selectedPlan.stake_Count ++;
 }

    // Function to claim rewards
    function unStaked(uint _plan_ID) external  {
    
        StakerInfo storage staker = stakers[msg.sender][staker_Count];
        uint elapsedTime = block.timestamp - staker.startTS;
        Plan storage selectedPlan = plans[_plan_ID];
         
        require(selectedPlan.in_Process == true ,"plan expired");

        uint reward = intrestAmount(msg.sender ,_plan_ID);
        tokenContract.transfer(msg.sender, reward);
        staker.claimed += reward;

        if (elapsedTime >= selectedPlan.end_Duration){
            selectedPlan.in_Process = false;
            staker.active = false;
        }
    }


    // Function to calculate the reward for a staker
      function intrestAmount(address staker_Address , uint _plan_ID) public view returns (uint) {
     
       StakerInfo storage staker = stakers[staker_Address][staker_Count];
       Plan storage selectedPlan = plans[_plan_ID];
       require(selectedPlan.in_Process == true ,"not a valid Plan ");

       uint elapsedTime = block.timestamp - staker.startTS;
       uint totalAmount = 0; 
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
       function CheckBalance() external view onlyOwner returns(uint) {
        uint256 contractBalance = tokenContract.balanceOf(address(this));
        require(
            contractBalance > 0,
            "Contract does not have any balance to withdraw"
        );
         return contractBalance;
    }
   
}
