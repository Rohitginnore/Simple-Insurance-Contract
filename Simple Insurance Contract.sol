// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleInsurance
 * @dev A minimal parametric insurance contract that provides coverage based on predefined conditions
 */
contract SimpleInsurance {
    address public owner;
    uint256 public premium;
    uint256 public coverageAmount;
    uint256 public minimumConditionValue;
    
    struct Policy {
        bool isActive;
        uint256 purchaseTime;
    }
    
    mapping(address => Policy) public policies;
    
    event PolicyPurchased(address indexed policyholder, uint256 premium, uint256 timestamp);
    event ClaimPaid(address indexed policyholder, uint256 amount, uint256 conditionValue);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    
    constructor(uint256 _premium, uint256 _coverageAmount, uint256 _minimumConditionValue) {
        owner = msg.sender;
        premium = _premium;
        coverageAmount = _coverageAmount;
        minimumConditionValue = _minimumConditionValue;
    }
    
    /**
     * @notice Allow users to purchase an insurance policy
     */
    function purchasePolicy() external payable {
        require(msg.value == premium, "Premium amount is incorrect");
        require(!policies[msg.sender].isActive, "Policy already exists");
        
        policies[msg.sender] = Policy({
            isActive: true,
            purchaseTime: block.timestamp
        });
        
        emit PolicyPurchased(msg.sender, premium, block.timestamp);
    }
    
    /**
     * @notice Process an insurance claim when conditions are met
     * @param _policyholder Address of the policyholder
     * @param _conditionValue The measured value that triggers coverage (e.g. rainfall)
     */
    function processClaim(address _policyholder, uint256 _conditionValue) external onlyOwner {
        require(policies[_policyholder].isActive, "No active policy found");
        require(_conditionValue <= minimumConditionValue, "Condition does not trigger payout");
        require(address(this).balance >= coverageAmount, "Insufficient contract balance");
        
        policies[_policyholder].isActive = false;
        
        payable(_policyholder).transfer(coverageAmount);
        
        emit ClaimPaid(_policyholder, coverageAmount, _conditionValue);
    }
}
