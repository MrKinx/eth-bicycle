// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BicycleRenting {
    
    address owner;
    uint ownerBalance;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
    require(msg.sender == owner, "Access restricted!");
    _;
    }

// Add Renter informations
//struct Session{
//    uint sessionId;
//    uint sessionStart;
//    uint sessionEnd;
//    uint sessionDue;
//}

event Session(
    uint indexed sessionId,
    address indexed renter,
    uint sessionStart,
    uint sessionEnd,
    uint sessionDue
);

struct Renter {
    string name;
    string lastName; 
    //address payable walletAddress; 
    uint256 start; 
    uint256 end; 
    bool active; 
    uint balance; 
    uint due;
    uint sessionNum;
}

mapping (address => Renter) public renters;
// mapping (uint => Session) public sessionDetails;
//mapping (address => mapping (uint => Session)) public sessions;

function addRenter(string memory name, string memory lastName, uint balance) public {
    renters[msg.sender] = Renter(name, lastName, 0, 0, false, balance, 0, 0);
}

// Start Rent
function reqBikeRide() public {
    require(canRentBike(msg.sender) == true, "You already have an active session");
    renters[msg.sender].start = block.timestamp;
    renters[msg.sender].active = true;
    renters[msg.sender].sessionNum ++;
    //sessions[msg.sender][renters[msg.sender].sessionNum].sessionId = renters[msg.sender].sessionNum;
}

// End Rent

function endBikeRide() public {
    require(renters[msg.sender].active == true, "You don't have an active session!");
    renters[msg.sender].end = block.timestamp;
    renters[msg.sender].active = false;
    setDue(msg.sender);
    //addSession(msg.sender, renters[msg.sender].sessionNum);
    newSession(renters[msg.sender].sessionNum, msg.sender, renters[msg.sender].start, renters[msg.sender].end, renters[msg.sender].due);
    makePayment(msg.sender);
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
function contractBalance() public view onlyOwner returns(uint){
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
//function addSession(address walletAddress, uint sessionId) internal{
//    sessions[walletAddress][sessionId].sessionStart = renters[walletAddress].start;
 //   sessions[walletAddress][sessionId].sessionEnd = renters[walletAddress].end;
 //   sessions[walletAddress][sessionId].sessionDue = renters[walletAddress].due;
//}

function newSession( uint id,address sender, uint start, uint end, uint due) internal {
    emit Session(id, sender, start, end, due);
}

}