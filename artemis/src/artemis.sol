// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Contract {
    // Structure to represent a betting event
    struct Event {
        string eventName; // e.g., "Champions League Final: Real Madrid vs. Liverpool"
        uint256 eventId;
        string[] outcomes; // e.g., ["Real Madrid", "Liverpool", "Draw"]
        uint256[] odds; // Odds for each outcome (as fractions, e.g., 2 for 2:1)
        uint256 endTime; // Timestamp when betting closes
        bool isResolved; // Whether the event outcome has been determined
        string winningOutcome; // The final result
        mapping(address => mapping(uint256 => uint256)) bets; // User bets per outcome (amount in wei)
        mapping(uint256 => uint256) totalBets; // Total bets per outcome
    }

    // Structure to track user balances (in native token, e.g., Ether)
    struct User {
        uint256 balance;
    }

    // Events for logging
    event BetPlaced(address indexed user, uint256 eventId, uint256 outcomeIndex, uint256 amount);
    event EventResolved(uint256 eventId, string winningOutcome);
    event Payout(address indexed user, uint256 amount);

    // State variables
    mapping(uint256 => Event) public events; // Events by ID
    mapping(address => User) public users; // User balances
    uint256 public eventCount; // Total number of events
    address public owner; // Contract owner for administrative tasks

    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Modifier to check if event exists and betting is open
    modifier validEvent(uint256 _eventId) {
        require(_eventId < eventCount, "Event does not exist");
        require(block.timestamp < events[_eventId].endTime, "Betting period closed");
        require(!events[_eventId].isResolved, "Event already resolved");
        _;
    }

    // Create a new betting event
    function createEvent(
        string memory _eventName,
        string[] memory _outcomes,
        uint256[] memory _odds,
        uint256 _endTime
    ) public onlyOwner {
        require(_outcomes.length == _odds.length, "Outcomes and odds must match");
        require(_endTime > block.timestamp, "End time must be in the future");

        Event storage newEvent = events[eventCount];
        newEvent.eventName = _eventName;
        newEvent.eventId = eventCount;
        newEvent.outcomes = _outcomes;
        newEvent.odds = _odds;
        newEvent.endTime = _endTime;
        newEvent.isResolved = false;

        eventCount++;
    }

    // Place a bet on an event outcome using native token (Ether)
    function placeBet(uint256 _eventId, uint256 _outcomeIndex) public payable validEvent(_eventId) {
        require(_outcomeIndex < events[_eventId].outcomes.length, "Invalid outcome");
        require(msg.value > 0, "Bet amount must be greater than 0");

        // Record the bet (amount in wei, as msg.value is in wei)
        events[_eventId].bets[msg.sender][_outcomeIndex] += msg.value;
        events[_eventId].totalBets[_outcomeIndex] += msg.value;

        emit BetPlaced(msg.sender, _eventId, _outcomeIndex, msg.value);
    }

    // Resolve an event with the winning outcome
    function resolveEvent(uint256 _eventId, string memory _winningOutcome) public onlyOwner {
        require(_eventId < eventCount, "Event does not exist");
        Event storage eventData = events[_eventId];
        require(!eventData.isResolved, "Event already resolved");
        require(block.timestamp > eventData.endTime, "Betting period not closed");

        eventData.isResolved = true;
        eventData.winningOutcome = _winningOutcome;

        emit EventResolved(_eventId, _winningOutcome);
    }

    // Claim winnings for a resolved event using native token (Ether)
    function claimWinnings(uint256 _eventId) public {
        require(_eventId < eventCount, "Event does not exist");
        Event storage eventData = events[_eventId];
        require(eventData.isResolved, "Event not resolved");

        uint256 winningIndex;
        for (uint256 i = 0; i < eventData.outcomes.length; i++) {
            if (keccak256(abi.encodePacked(eventData.outcomes[i])) == keccak256(abi.encodePacked(eventData.winningOutcome))) {
                winningIndex = i;
                break;
            }
        }
        require(winningIndex < eventData.outcomes.length, "Winning outcome not found");

        uint256 userBet = eventData.bets[msg.sender][winningIndex];
        require(userBet > 0, "No bet placed on winning outcome");

        // Calculate payout: bet amount * odds
        uint256 payout = userBet * eventData.odds[winningIndex];
        
        // Transfer native token (Ether) to the user
        (bool sent, ) = msg.sender.call{value: payout}("");
        require(sent, "Failed to send Ether");

        // Reset user's bet for this outcome
        eventData.bets[msg.sender][winningIndex] = 0;

        emit Payout(msg.sender, payout);
    }

    // Function to withdraw funds (for owner, if needed, e.g., for contract maintenance)
    function withdraw(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient contract balance");
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "Failed to withdraw Ether");
    }

    // Function to check contract balance (for debugging or transparency)
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}