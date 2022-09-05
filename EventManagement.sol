// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract EventManagement{

    //create a structure of the event
    struct Event{
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextId;

    //create a function for create an event.
    function createEvent(string memory name, uint date, uint price, uint ticketCount) external {
        require(date > block.timestamp, "You can organize event for future date");
        require(ticketCount > 0, "Ticket count must be greater than 1");

        events[nextId] = Event(msg.sender, name, date, price, ticketCount, ticketCount);
        nextId++;
    }

    //function for buy ticket
    function buyTicket(uint id, uint quantity) external payable{
        require(events[id].date!=0, "This event doesn't exist.");
        require(events[id].date > block.timestamp,"Event has already occured.");
        Event storage _event = events[id];
        require(msg.value == (_event.price*quantity),"Ether is not enough");
        require(_event.ticketRemain >= quantity, "Not enough tickets");
        _event.ticketRemain -= quantity;
        tickets[msg.sender][id]+=quantity;
    }

    //function for transfer ticket
    function transferTicket(uint id, uint quantity, address to) external{
        require(events[id].date!=0, "This event doesn't exist.");
        require(events[id].date > block.timestamp,"Event has already occured.");
        require(tickets[msg.sender][id] >= quantity, "You do not have enoug tickets");
        tickets[msg.sender][id] -= quantity;
        tickets[to][id]+=quantity;
    }
}
