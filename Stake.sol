//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "hardhat/console.sol";

/**
    REWARD SYSTEM : Can be discount fee from NFT trading/purchasing. For example, we can take %0.004 fee for each
    NFT trade. When user stake, the fee discounted ~60-70% according to stake amount and stake duration.
 */


contract Stake {

    address public immutable owner; // owner, who deployed the contract.
    
    mapping(address => StakeObject) public stakePool; // stores address and stake informations.

    uint256 public stakerCount; // counter for staker number.

    //stake struct storage stake informations.
    struct StakeObject{
        uint256 amount; // amount of stake
        uint8 stakeDuration; // choosen duration of stake 1-7-30 days
        uint256 stakeAddedTime; // time of stake added. To calculate withdraw time.
    }

    event StakeEvent(address _addr, uint _amount, uint8 stakeDuration, uint256 _timestamp); // Event when user stake.
    event WithdrawEvent(address _addr, uint256 _amount, uint256 _timestamp); //Event when user withdraw.



    constructor(){
        owner = msg.sender;
    }

    //Minimum stake duration is 1 Day, 24 Hours

    /*
    *@dev Calculates the discount of fee according to user's stake volume and time period of the stake.
    * Fee discount would be 90% maximum.
    */
    function calculateReward(address _addr) public view returns(uint256){
      uint256 reward = ((stakePool[_addr].amount)/10000); // for now calculates %0.01 reward of stake
      return reward;
    }


    /*
    @dev Protect withdraw and stake functions from reentrancy attack. Before function executed, locked variable
    is unassigned so it is "false", and require is satisfied. and locked is turn into "true" until the function is finished.
    Then locked back to "false". With this modifier function is execute just one time during the process.
    */
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    /*
    *@dev Stake function that users can stake for a limited time. Time duration is Radio Button 1-7-30
    * Takes amount with msg.value
    */
    function stake(uint8 stakeDuration) external payable noReentrant{
       require(controlStaker(msg.sender),"You can not stake before you withdraw your balance");
       StakeObject memory stakeObj= StakeObject(msg.value, stakeDuration, block.timestamp);
       stakePool[msg.sender] = stakeObj;
       stakerCount++;
       emit StakeEvent(msg.sender, msg.value, stakeDuration, block.timestamp);
    }

    //Shows current time.
    function showTime() public view returns(uint256){
        return block.timestamp;
    }

    /*
    *@dev Users can not withdraw before selected time is passed. After that time liquidity can be withdraw with
    *     calculated reward.
    */
    function withdraw() public noReentrant{
        require(controlStakeDuration(msg.sender),"Your stake duration is not finished");
        uint balanceWithReward = stakePool[msg.sender].amount + calculateReward(msg.sender);
        (bool sent,) = msg.sender.call{value: balanceWithReward}("");
        require(sent, "Withdraw is not completed, try again");
        emit WithdrawEvent(msg.sender, stakePool[msg.sender].amount, block.timestamp);
        stakerCount--;
        stakePool[msg.sender].amount = 0;
        stakePool[msg.sender].stakeAddedTime = 0;
        stakePool[msg.sender].stakeDuration = 0;
        

    }

    /*
    *@dev Shows balance of user who staked.
    */
    function showBalance(address _addr) public view returns(uint256){
        return stakePool[_addr].amount;
    }


    /*
    *@dev Shows choosen stake duration of user who staked.
    */
    function showStakeDuration(address _addr) public view returns(uint256){
        return stakePool[_addr].stakeDuration;
    }


    /*
    @dev Controls if users who has been staked before. If there is stake balance of the user,
    program won't let to stake again before withdraw.
    */
    function controlStaker(address _addr) private view returns(bool){
        if(stakePool[_addr].amount == 0){
            return true;
        }
        return false;
    }

    /*
    *@dev Controls the stake duration of the user who wants to withdraw. If time has passed, user can withdraw
          his/him balance with reward. Otherwise can not. 
    */
    function controlStakeDuration(address _addr) internal view returns(bool){
        uint256 duration = stakePool[_addr].stakeDuration;
        uint256 stakeAddedTime = stakePool[_addr].stakeAddedTime;

        if(duration == 1){
            return stakeAddedTime + 24 hours < showTime() ? true:false;
        }

        else if(duration == 7){
            return stakeAddedTime + 168 hours < showTime() ? true:false;
        }

         else if(duration == 30){
            return stakeAddedTime + 720 hours < showTime() ? true:false;
        }

        else{
            return false;
        }
        
    }

    /*
    @dev receive() and fallback() doesn't take ether. User just can stake with function.
    */
    receive() external payable{
        revert("You can not send ETH to contract");
    }

    fallback() external payable{
        revert("You can not send ETH to contract");
    }

}