//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract is Ownable { 

    uint maxAmount;
    uint minAmount;
    uint public userCount;
    IERC20 public token;

    struct userInfo {
        uint amount;
        uint claimed;
        uint interestRate;
        uint month;
        uint startTS;
        uint endTS;
        bool active;
    }
    event Claimed(address indexed from, uint256 amount);
    mapping(address=>mapping(uint=>userInfo)) public User;
    mapping (address => uint) public userToCount;
   

    constructor(address _address) {
        token = IERC20(_address);
    }

    function stake(uint _amount, uint _month) external  returns(bool){
         require(userToCount[msg.sender] < 5 ,"You can't stake more than 5 times ");
         require(_amount < maxAmount, "you have to spend less");
         require(_amount > minAmount, "you have to spend more");
         
        token.transferFrom(msg.sender,address(this), _amount);
        userToCount[msg.sender] +=1;
        uint _intrest;
        uint _endTS;
       // uint secondInMonth = 2629743;
        if(_month < 3){
            _intrest = 22;
            _endTS = 50; //block.timestamp + 3 * secondInMonth;
        }else if(_month < 6){
             _intrest = 50;
            _endTS = 100;//block.timestamp + 6 * secondInMonth;
        }
         else if(_month < 12){
             _intrest = 50; 
            _endTS = 150;// block.timestamp + 12 * secondInMonth;
        }
         User[msg.sender][userToCount[msg.sender]] = userInfo({              
                amount: _amount,
                claimed:0,
                interestRate: _intrest,
                month: _month,
                startTS: block.timestamp,
                endTS: block.timestamp + _endTS,
                active:true
            });
            userCount++;
            
          return true;
    }

    function unStake(uint _userCount )external returns(bool){
        userInfo storage user = User[msg.sender][_userCount];
        require(user.active == true,"allready unstake");
        require(block.timestamp >= user.endTS, "Cannot unstake before endTS");
        uint reward = (user.amount * user.interestRate * user.month)/ 100 ;
        token.transfer(msg.sender, reward);
        user.claimed += reward;
        user.active = false;
        emit Claimed(msg.sender,reward);
        return (true);
 }

    function upDate_MaxAmount(uint _maxAount) external  onlyOwner returns (uint) {
        maxAmount = _maxAount;
        return(maxAmount);
    }
    
    function upDate_MinAmount(uint _minAount) external onlyOwner returns (uint) {
        minAmount = _minAount;
        return(minAmount);
    }
    
}