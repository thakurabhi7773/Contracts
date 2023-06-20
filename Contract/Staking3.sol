 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Context.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract StakingContract is Context {

    uint256 public totalStaked;
    uint256 public constant MAX_PLANS = 5;
   
    
    // // 30 Days (30 * 24 * 60 * 60)
    // uint256 public planDuration = 2592000;

    // // 90 Days (180 * 24 * 60 * 60)
    // uint256 public _planExpired = 7776000;
    //  uint256 public planExpired;


    struct stakerInfo {
        uint256 balance;
        uint256 claimed; 
        uint256 startTS;
        // uint256 endTS; 
        uint256 selectedPlanIndex;
        bool active;
    }

    struct Plan {
        uint256 duration;
        uint256 rewardPercentage;
    }
  

    event Claimed(address indexed from, uint256 amount);
    mapping(address => stakerInfo) public stakers;
   
    IERC20 public tokenContract;
    Plan[] public plans;

    constructor(address _tokenContract) {
        tokenContract = IERC20(_tokenContract);
        //   planExpired = block.timestamp + _planExpired;
    }

    // Modifier to check if the staker has a positive balance
    modifier positiveBalance() {
        require(stakers[msg.sender].balance > 0, "No balance to claim rewards");
        _;
    }

    // Modifier to check if the plan index is valid
    modifier validPlanIndex(uint256 planIndex) {
        require(planIndex < plans.length, "Invalid plan index");
        _;
    }

    // Function to add a new plan
    function addPlan(uint256 duration, uint256 rewardPercentage) external {
        require(plans.length < MAX_PLANS, "Maximum number of plans reached");

        Plan memory newPlan = Plan(duration, rewardPercentage);
        plans.push(newPlan);
    }

    // Function to stake tokens and select a plan
    function stakeTokens(uint256 amount, uint256 planIndex) external validPlanIndex(planIndex) {
        require(amount > 0, "Amount should be greater than 0");
        // require(block.timestamp < planExpired , "Plan Expired");
        // Transfer tokens from the sender to the contract
        require(tokenContract.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        // Update staker's balance and selected plan
        stakers[msg.sender].balance += amount;
        stakers[msg.sender].selectedPlanIndex = planIndex;
        totalStaked += amount;

        // Update last update time
        stakers[msg.sender].startTS = block.timestamp;

        // updated the stakerInfo
         stakers[msg.sender] = stakerInfo({                
                balance: amount,
                claimed:Rewards, 
                active:true,
                selectedPlanIndex:planIndex,
                startTS:block.timestamp
                // endTS:block.timestamp + planDuration
            });
    }

    // Function to claim rewards
    function claimRewards() external positiveBalance {
        uint reward = calculateReward(msg.sender);

        // Reset last update time
        stakers[msg.sender].startTS = block.timestamp;

        // Transfer rewards to the staker
        require(tokenContract.transfer(msg.sender, reward), "Token transfer failed");

        // Update staker's balance
        stakers[msg.sender].balance += reward;
    }

    // Function to calculate the reward for a staker
    function calculateReward(address stakerAddress) public view returns (uint256) {
        stakerInfo memory staker = stakers[stakerAddress];
        uint256 elapsedTime = block.timestamp - staker.startTS;

        if (elapsedTime == 0) {
            return 0;
        }

        Plan memory selectedPlan = plans[staker.selectedPlanIndex];
        return (staker.balance * selectedPlan.rewardPercentage * elapsedTime) / (100 * selectedPlan.duration);
    }
}