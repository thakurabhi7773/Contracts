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
    uint public user_Count;
    uint256 private planCount;
    
  
    struct stakerInfo {
        uint256 staked_Amount;
        uint256 claimed; 
        uint256 startTS; 
        uint256 selected_PlanIndex;
        bool active;
    }

    struct plan {
        address planer;
        uint256 duration;
        uint256 rewardPercentage;
        bool inProcess;
    }
  

    event Claimed(address indexed from, uint256 amount);
    mapping(address => stakerInfo) public stakers;
    mapping (uint => plan) public Plans;
    mapping(address => uint) public User_Count;
    
    IERC20 public tokenContract;
   

    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
       //   planExpired = block.timestamp + _planExpired;
 }

  // Function to add a new plan
    function addPlan(uint256 _duration, uint256 intrestPercentage) external  {
      
          Plans[planCount]=plan({
           planer: msg.sender,
           duration: _duration,
           rewardPercentage: intrestPercentage,
           inProcess: true
       });
          
           planCount++;
 }

    // Function to stake tokens and select a plan
    function Stake(uint256 amount, uint256 planIndex) external {

       require(amount > 0, "Amount should be greater than 0");
       require(User_Count[msg.sender] < 5 ,"You can't stake more than 5 times ");
 
      
        tokenContract.transferFrom(msg.sender, address(this), amount);
        totalStakedAmount += amount;
        stakers[msg.sender] = stakerInfo({                
                staked_Amount: amount,
                claimed:0,
                active:true,
                selected_PlanIndex:planIndex,
                startTS:block.timestamp
                
        });
        user_Count++;
    }

    // Function to claim rewards
    function unStaked() external  {

        require(stakers[msg.sender].staked_Amount > 0);
    uint reward = intrestAmount(msg.sender);
        stakers[msg.sender].startTS = block.timestamp;
        tokenContract.transfer(msg.sender, reward);
        stakers[msg.sender].claimed += reward;
        uint claimed_Amount = stakers[msg.sender].claimed; 
        uint stake_Amount_Interest = (stakers[msg.sender].staked_Amount * Plans[stakers[msg.sender].selected_PlanIndex].rewardPercentage)/100 ;
        require(stake_Amount_Interest >= claimed_Amount ,"you can't  Unstake now " );

        if(block.timestamp - stakers[msg.sender].startTS > Plans[stakers[msg.sender].selected_PlanIndex].duration)
        {
         stakers[msg.sender].active == false;
         Plans[planCount].inProcess = false;
        }
       
    }


    // Function to calculate the reward for a staker
    function intrestAmount(address stakerAddress) public view returns (uint256) {
       stakerInfo memory staker = stakers[stakerAddress];
       plan memory selectedPlan = Plans[staker.selected_PlanIndex];
       uint256 elapsedTime = block.timestamp - staker.startTS;

     if (block.timestamp < (Plans[staker.selected_PlanIndex].duration + staker.startTS) - elapsedTime) {
       return  ((staker.staked_Amount * selectedPlan.rewardPercentage * elapsedTime) / (100 *selectedPlan.duration));
    }
     else { 
         uint endTime =  Plans[staker.selected_PlanIndex].duration ;
       return ((staker.staked_Amount * selectedPlan.rewardPercentage * endTime) / (100 *selectedPlan.duration)) - stakers[msg.sender].claimed ;
    }
     
 }
}




  
    // // 30 Days (30 * 24 * 60 * 60)
    // uint256 public planDuration = 2592000;

    // // 90 Days (180 * 24 * 60 * 60)
    // uint256 public _planExpired = 7776000;
    //  uint256 public planExpired;








//    function intrestAmount(address stakerAddress) public view returns (uint256) {
//         stakerInfo memory staker = stakers[stakerAddress];
//         uint256 elapsedTime = block.timestamp - staker.startTS;

//         if (elapsedTime == 0) {
//             return 0;
//         }

//         plan memory selectedPlan = Plans[staker.selectedPlanIndex];
//         return (staker.balance * selectedPlan.rewardPercentage * elapsedTime) / (100 * selectedPlan.duration);
//     }
// }





  
    // // 30 Days (30 * 24 * 60 * 60)
    // uint256 public planDuration = 2592000;

    // // 90 Days (180 * 24 * 60 * 60)
    // uint256 public _planExpired = 7776000;
    //  uint256 public planExpired;










// contract Staking is Context{
//     struct Member_Information {
//      address member;
//      uint tokenOwn;
// }
//     address public Owner;
//     uint16 public tokenSupply;
//     uint16 public intrestRate;
//     uint256 public withdrawalTime;
//     uint public no_Of_Members;
//     uint256 _withdrawalTime = 15552000;
//     // 180 Days (180 * 24 * 60 * 60)
 

//   mapping(address => Member_Information) public Member;
//   mapping(address => uint ) _enteredMember;
//   mapping(address => bool ) enteredMember;
//   mapping(address => uint) public balance;
//    event Transfer(address indexed from,address indexed to ,uint256 amount);
  
//   constructor(uint16 _token , uint16 _interstRate ){
//       Owner = msg.sender;
//       tokenSupply = _token;
//       balance[Owner] = _token;
//       intrestRate = _interstRate;
//       withdrawalTime = block.timestamp + _withdrawalTime;
//   }

//   function _transfer(address from,address to,uint16 amount) public payable {
//       require(tokenSupply >= amount,"not enough Token" );
//       require(balance[from] > amount,"not enough Token" );
//       require(from != address(0)," transfer from the zero addres " );
//       require(to != address(0)," transfer to the zero addres " );
//       tokenSupply -= amount;
//       balance[from] -= amount;
//       balance[to] +=amount;
   
//     if(_enteredMember[msg.sender] ==0)
//         no_Of_Members++;
//        enteredMember[msg.sender] = true;
//       _enteredMember[msg.sender] += 1;
      
//        Member[_msgSender()] = Member_Information({                
//         member: msg.sender,
//         tokenOwn: balance[msg.sender]
//     });
//     emit Transfer(from,to, amount);
   

// }
// }