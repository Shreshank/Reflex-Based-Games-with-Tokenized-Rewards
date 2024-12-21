// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReflexGameRewards {

    // Token details
    string public name = "ReflexGameToken";
    string public symbol = "RGT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event RewardsDistributed(address indexed player, uint256 rewardAmount);

    // Game Owner
    address public gameOwner;

    // Reward pool
    uint256 public rewardPool;

    modifier onlyOwner() {
        require(msg.sender == gameOwner, "Only the game owner can perform this action");
        _;
    }

    constructor(uint256 _initialSupply) {
        gameOwner = msg.sender;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balanceOf[gameOwner] = totalSupply;
        emit Transfer(address(0), gameOwner, totalSupply);
    }

    // Basic ERC20 functions
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Reward distribution
    function distributeRewards(address _player, uint256 _rewardAmount) public onlyOwner {
        require(_rewardAmount <= rewardPool, "Not enough tokens in the reward pool");
        balanceOf[gameOwner] -= _rewardAmount;
        balanceOf[_player] += _rewardAmount;
        rewardPool -= _rewardAmount;
        emit RewardsDistributed(_player, _rewardAmount);
    }

    // Add tokens to the reward pool
    function fundRewardPool(uint256 _amount) public onlyOwner {
        require(balanceOf[gameOwner] >= _amount, "Insufficient tokens to fund the reward pool");
        rewardPool += _amount;
    }
}
