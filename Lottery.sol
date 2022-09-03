// SPDX-License-Identifier: MIT

pragma solidity  >= 0.5.0 < 0.9.0;

contract Lottery{

    address public manager;
    address payable[] public participants;

    constructor(){
        manager = msg.sender;
    } 

    //this function takes ether from participants and will be added into our contract address
    receive() external payable{
        require(msg.value == 1 ether);
        participants.push(payable(msg.sender));
    }

    //function to show the contract balance. Only manager can call this function
    function getBalance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }

    //function to generate a random number
    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    //function to check the winner and transfer the winnning amount
    function selectWinner() public{
        require(msg.sender == manager);
        require(participants.length >= 3);
        uint r = random();
        address payable winner;
        uint index = r % participants.length;
        winner = participants[index];
        winner.transfer(getBalance());
        participants = new address payable[](0); 
    }

}
