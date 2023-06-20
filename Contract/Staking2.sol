// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract is Ownable {

    uint256 public totalStakedAmount;
    uint256 private planCount;
    

    
  
    struct stakerInfo {
        uint256 balance;
        uint256 claimed; 
        uint256 startTS;
         
        uint256 selectedPlanIndex;
        bool active;
    }

    struct plan {
        address planer;
        uint256 duration;
        uint256 rewardPercentage;
        bool inProcess;
    }
  

    event Claimed(address indexed from, uint256 amount);
    mapping(address =>mapping(uint => stakerInfo)) public stakers;
    mapping (uint => plan) public Plans;
 
   
   // mapping (address => uint)IntrestCount;

    IERC20 public tokenContract;
   

    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
       //   planExpired = block.timestamp + _planExpired;
 }

  // Function to add a new plan
    function addPlan(uint256 _duration, uint256 intrestPercentage) external onlyOwner {
      
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
       tokenContract.transferFrom(msg.sender, address(this), amount);
       totalStakedAmount += amount;

        stakers[msg.sender][planIndex] = stakerInfo({                
                balance: amount,
                claimed:0,
                active:true,
                selectedPlanIndex:planIndex,
                startTS:block.timestamp
                 //endTS;block.timestamp + planDuration
            });
           

    }

    // Function to claim rewards
    function unStaked(uint plan_Index) external onlyOwner {

        require(stakers[msg.sender][plan_Index].balance > 0);
       // require(block.timestamp < Plans[stakers[msg.sender].selectedPlanIndex].duration,"plan expired");
        uint reward = intrestAmount(msg.sender,plan_Index);
        stakers[msg.sender][plan_Index].startTS = block.timestamp;
        tokenContract.transfer(msg.sender, reward);
        stakers[msg.sender][plan_Index].claimed += reward;
      // if(block.timestamp < Plans[stakers[msg.sender].selectedPlanIndex].duration + stakers[msg.sender].startTS){
    // }
    }


    // Function to calculate the reward for a staker
    function intrestAmount(address stakerAddress , uint plan_Index) public view returns (uint256) {
       stakerInfo memory staker = stakers[stakerAddress][plan_Index];
       plan memory selectedPlan = Plans[staker.selectedPlanIndex];
       uint256 elapsedTime = block.timestamp - staker.startTS;
       uint256 totalAmount = 0; 
       uint endTime =   Plans[staker.selectedPlanIndex].duration ;
      if (elapsedTime < endTime)
       {
         totalAmount =  ((staker.balance * selectedPlan.rewardPercentage * elapsedTime) / (100 *selectedPlan.duration)) - staker.claimed;
       }
     else { 
         totalAmount = ((staker.balance * selectedPlan.rewardPercentage * endTime) / (100 *selectedPlan.duration)) -staker.claimed + staker.balance;
      //  return ((staker.balance * selectedPlan.rewardPercentage * endTime) / (100 *selectedPlan.duration)) - stakers[msg.sender].claimed ;
       }
      return totalAmount;
    
 }
}






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