// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract CrowdFunding{

    mapping (address=>uint) public contributors;  //to store contributors amount (address => raisedAmount)
    address public manager;
    uint public minContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    //create a structure for making request to access the funding contract amount(only manager can access this)
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public numRequests;

    constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline; 
        minContribution = 100 wei;
        manager = msg.sender;
    }

    //function to donate eth to the smart contract
    function sendEth() public payable {
        require(block.timestamp < deadline, "Deadline has Passed"); //check wheather deadline is valid or not
        require(msg.value >= minContribution, "Minimum contribution is not met");  //check for min contribution

        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    //function to view the contract balance
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    //function to raise for refund
    function refund() public {
        require(block.timestamp > deadline && raisedAmount < target, "You are not eligible for refund.");
        require(contributors[msg.sender] > 0, "You didn't contributed any amount yet.");
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }

    //create a modifier for manager
    modifier onlyManager(){
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    //function to create a request(only manager can access the function)
    function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManager{
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    //function to create a vote request
    function voteRequest(uint _requestNo) public{
        require(contributors[msg.sender] > 0, "You must be a contributor");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false, "You have already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    //function to make payment to the recipient
    function makePayment(uint _requestNo) public {
        require(raisedAmount >= target, "Target of the crowdFunding not reached yet.");
        Request storage thisRequest = requests[_requestNo];
        require(thisRequest.completed == false, "The request has been completed.");
        require(thisRequest.noOfVoters > noOfContributors/2, "Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}
