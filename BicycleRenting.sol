// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BicycleRenting {
    
    address owner;

    constructor() {
        owner = msg.sender;

    }

// Add Renter informations

struct Renter {
    string name;
    string lastName; 
    address payable walletAddress; 
    uint256 start; 
    uint256 end; 
    bool canRent; 
    bool active; 
    uint balance; 
    uint due;
}

mapping (address => Renter) public renters;

function addRenter(string memory name, string memory lastName,  address payable walletAddress,  uint256 start,  uint256 end,  bool canRent,  bool active,  uint balance,  uint due) public {
    renters[walletAddress] = Renter(name, lastName,walletAddress, start, end, canRent, active, balance, due);
}

// Renting request (Check in)

// Ending renting (Check out)

// Total stats

// Get Contract balance

// get Renter's balance

// Set Renter's Due amount


}