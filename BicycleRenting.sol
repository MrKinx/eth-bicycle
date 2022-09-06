// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BicycleRenting {
    
    address owner;
   // uint fee;

    constructor() {
        owner = msg.sender;
    }

// Add Renter informations
struct Session{
    uint sessionId;
    uint sessionStart;
    uint sessionEnd;
    uint sessionDue;
}

struct Renter {
    string name;
    string lastName; 
    address payable walletAddress; 
    uint256 start; 
    uint256 end; 
    bool active; 
    uint balance; 
    uint due;
    uint sessionNum;
}

mapping (address => Renter) public renters;
// mapping (uint => Session) public sessionDetails;
mapping (address => mapping (uint => Session)) public sessions;

function addRenter(string memory name, string memory lastName,  address payable walletAddress, uint balance) public {
    renters[walletAddress] = Renter(name, lastName,walletAddress, 0, 0, false, balance, 0, 0);
}

// Start Rent
function reqBikeRide(address walletAddress) public {
    require(canRentBike(walletAddress) == true, "You already have an active session");
    renters[walletAddress].start = block.timestamp;
    renters[walletAddress].active = true;
    renters[walletAddress].sessionNum ++;
    sessions[walletAddress][renters[walletAddress].sessionNum].sessionId = renters[walletAddress].sessionNum;
}

// End Rent

function endBikeRide(address walletAddress) public {
    require(renters[walletAddress].active == true, "You don't have an active session!");
    renters[walletAddress].end = block.timestamp;
    renters[walletAddress].active = false;
    setDue(walletAddress);
    addSession(walletAddress, renters[walletAddress].sessionNum);
    makePayment(walletAddress);
}

// Get session duration
function getTimeDif (uint end, uint start) internal pure returns(uint) {
    return end - start;
}

function getSessionDuration (address walletAddress) public view returns(uint){
    require(renters[walletAddress].active == false, "You have an ongoing session!");
    uint thisSession = getTimeDif(renters[walletAddress].end, renters[walletAddress].start);
    return thisSession;
}

// Get Contract balance
function contractBalance() public view returns(uint){
    require(msg.sender == owner, "Only owner can execute this function!");
    return address(this).balance;
}

// Add Money to balance
function deposit(address walletAddress) public payable {
    renters[walletAddress].balance += msg.value;
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

// Set Payment
function makePayment(address walletAddress) public payable {
    require(renters[walletAddress].due > 0, "No active payment were found!");
    require(renters[walletAddress].balance >= msg.value, "Not enough balance!");
    renters[walletAddress].balance -= renters[walletAddress].due;
    renters[walletAddress].due = 0;
    renters[walletAddress].start = 0;
    renters[walletAddress].end = 0;
}

//Check rent request order
function canRentBike(address walletAddress) public view returns(bool){
    if(renters[walletAddress].active == false && renters[walletAddress].due == 0){
        return (true);
    }
    else{
        return(false);
    }

}

//Add Session Record
function addSession(address walletAddress, uint sessionId) internal{
    sessions[walletAddress][sessionId].sessionStart = renters[walletAddress].start;
    sessions[walletAddress][sessionId].sessionEnd = renters[walletAddress].end;
    sessions[walletAddress][sessionId].sessionDue = renters[walletAddress].due;
}

}