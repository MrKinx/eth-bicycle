// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BicycleRenting {
    
    address owner;
    uint fee;

    constructor(uint setFee) {
        owner = msg.sender;
        fee = setFee;

    }

// Add Renter informations

struct Renter {
    string name;
    string lastName; 
    address payable walletAddress; 
    uint256 start; 
    uint256 end; 
    bool active; 
    uint balance; 
    uint due;
}

mapping (address => Renter) public renters;

function addRenter(string memory name, string memory lastName,  address payable walletAddress,  uint256 start,  uint256 end,  bool canRent,  bool active,  uint balance,  uint due) public {
    renters[walletAddress] = Renter(name, lastName,walletAddress, start, end, active, balance, due);
}

// Renting request (Check in)

function checkInBike(address walletAddress) public {
    require(renters[walletAddress].active == false);
    renters[walletAddress].start = block.timestamp;
    renters[walletAddress].active = true;

}

// Ending renting (Check out)

function checkOutBike(address walletAddress) public {
    require(renters[walletAddress].active == true);
    renters[walletAddress].end = block.timestamp;
    renters[walletAddress].active = false;
    setDue(walletAddress);

}

// Get session duration
function getTimeDif (uint end, uint start) internal pure returns(uint) {
    return end - start;
}

function getSessionDuration (address walletAddress) public view returns(uint){
    require(renters[walletAddress].active == false, "You have an ongoing session!");
    uint thisSession = getTimeDif(renters[walletAddress].end, renters[walletAddress].start);
    uint sessionInMinutes = thisSession/60;
    return sessionInMinutes;
}

// Get Contract balance
function contractBalance() public view returns(uint){
    require(msg.sender == owner, "Only owner can execute this function");
    return address(this).balance;
}

// Get Renter's balance
function balanceOfRenter(address walletAddress) public view returns(uint){
    return renters[walletAddress].balance;
}

// Set Renter's Due amount
function setDue(address walletAddress) internal{
    uint sessionTime = getSessionDuration(walletAddress);
    renters[walletAddress].due = sessionTime * 5000000000000000;
}
function deductDue(address walletAddress) internal{
    renters[walletAddress].balance = renters[walletAddress].balance -  renters[walletAddress].due;
}

function canRentBike(address walletAddress) public view returns(bool){
    return (!renters[walletAddress].active);
}

}