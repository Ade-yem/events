// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 < 0.9.0;

/**
 * @title Event creator contract
 * @author Adeyemi
 * @notice 
 */

contract EventContract {
    struct Event {
        uint256 id;
        address owner;
        string name;
        uint256 price;
        uint256 time;
        bytes32 details;
        bool completed;
    }
    address public owner;
    uint256 private count = 0;
    mapping (string => Event) public events;
    mapping (address => uint256) public creatorBalance;
    // mapping to list of the names of events a user registered for
    // parsing for it can be done on the client side
    mapping (address => string[]) public eventsRegistry;
    Event[] public eventList;
    event EventCreated(string name, address creator, uint256 price, uint256 time);
    event EventEdited(string name, address creator, uint256 price, uint256 time);
    event RegisteredForEvent(string nameOfEvent, address attendee, uint256 time);
    event WithdrawFunds(address who, uint256 amount);
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * Creates an event
     * @param name name of the event
     * @param price price of the event
     * @param time time of the event
     * @param details details of the event
     */
    function createEvent(string memory name, uint256 price, uint256 time, bytes32 details) public {
        count += 1;
        Event memory item = Event(count, msg.sender, name, price, time, details, false);
        events[name] = item;
        eventList.push(item);
        creatorBalance[msg.sender] += 0;
        emit EventCreated(name, msg.sender, price, time);
    }

    /**
     * Edits an event
     * @param name name of the event
     * @param price price of the event
     * @param time time of the event
     * @param details details of the event
     */
    function editEvent(string memory name, uint256 price, uint256 time, bytes32 details) public {
        events[name].price = price;
        events[name].time = time;
        events[name].details = details;
        emit EventEdited(name, msg.sender, price, time);
    }

    /**
     * Gets an event with its name
     * @param name name of the event
     * @return event struct
     */
    function getEvent(string memory name) public view returns (Event memory) {
        return events[name];
    }

    /**
     * Register for an event
     * @param nameOfEvent name of the event
     * it should return an nft for confirmation
     */
    function registerForEvent(string memory nameOfEvent) payable public {
        if (events[nameOfEvent].completed) {
            revert("Event has been completed");
        }
        if (msg.value < events[nameOfEvent].price) {
            revert("You cannot pay less than the price");
        }
        creatorBalance[events[nameOfEvent].owner] += msg.value;
        // mint nft for the event invite
        eventsRegistry[msg.sender].push(nameOfEvent);
        emit RegisteredForEvent(nameOfEvent, msg.sender, events[nameOfEvent].time);
    }

    /**
     * Withdraw funds
     */
    function withdrawFunds() public {
        if (creatorBalance[msg.sender] <= 0) {
            revert("We do not have your money");
        }
        payable(msg.sender).transfer(creatorBalance[msg.sender]);

        creatorBalance[msg.sender] = 0;
        emit WithdrawFunds(msg.sender, creatorBalance[msg.sender]);
    }
}