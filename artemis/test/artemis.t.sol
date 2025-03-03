// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/artemis.sol";

contract ContractTest is Test {
    Contract public contractInstance;
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    uint256 constant INITIAL_BALANCE = 100 ether; // Ether for testing

    function setUp() public {
        // Deploy the contract
        vm.startPrank(owner);
        contractInstance = new Contract();
        vm.stopPrank();

        // Fund users with Ether for testing
        vm.deal(owner, INITIAL_BALANCE);
        vm.deal(user1, INITIAL_BALANCE);
        vm.deal(user2, INITIAL_BALANCE);
    }

    // Test creating a new betting event
    function testCreateEvent() public {
        vm.startPrank(owner);
        string memory eventName = "Champions League Final: Real Madrid vs. Liverpool";
        string[] memory outcomes = new string[](3);
        outcomes[0] = "Real Madrid";
        outcomes[1] = "Liverpool";
        outcomes[2] = "Draw";
        uint256[] memory odds = new uint256[](3);
        odds[0] = 2; // 2:1 odds
        odds[1] = 2; // 2:1 odds
        odds[2] = 3; // 3:1 odds
        uint256 endTime = block.timestamp + 1 days;

        contractInstance.createEvent(eventName, outcomes, odds, endTime);
        uint256 eventId = contractInstance.eventCount() - 1;

        contractInstance.Event memory eventData = contractInstance.events(eventId);
        assertEq(eventData.eventName, eventName, "Event name mismatch");
        assertEq(eventData.outcomes.length, 3, "Outcomes length mismatch");
        assertEq(eventData.odds.length, 3, "Odds length mismatch");
        assertEq(eventData.endTime, endTime, "End time mismatch");
        assertFalse(eventData.isResolved, "Event should not be resolved");
        vm.stopPrank();
    }

    // Test placing a bet with native token (Ether)
    function testPlaceBet() public {
        uint256 eventId = _createSampleEvent();

        // User1 places a bet on outcome 0 (Real Madrid) with 1 Ether
        vm.startPrank(user1);
        (bool sent, ) = address(contractInstance).call{value: 1 ether}(
            abi.encodeWithSignature("placeBet(uint256,uint256)", eventId, 0)
        );
        require(sent, "Bet placement failed");

        Event memory eventData = contractInstance.events(eventId);
        assertEq(eventData.bets[user1][0], 1 ether, "Bet amount mismatch for user1");
        assertEq(eventData.totalBets[0], 1 ether, "Total bets mismatch");
        vm.stopPrank();
    }

    // Test resolving an event
    function testResolveEvent() public {
        uint256 eventId = _createSampleEvent();
        vm.warp(block.timestamp + 2 days); // Move past endTime

        vm.startPrank(owner);
        contractInstance.resolveEvent(eventId, "Real Madrid");
        Event memory eventData = contractInstance.events(eventId);
        assertTrue(eventData.isResolved, "Event should be resolved");
        assertEq(
            keccak256(abi.encodePacked(eventData.winningOutcome)),
            keccak256(abi.encodePacked("Real Madrid")),
            "Winning outcome mismatch"
        );
        vm.stopPrank();
    }

    // Test claiming winnings
    function testClaimWinnings() public {
        uint256 eventId = _createSampleEvent();

        // User1 places a bet on the winning outcome (Real Madrid)
        vm.startPrank(user1);
        (bool sent, ) = address(contractInstance).call{value: 1 ether}(
            abi.encodeWithSignature("placeBet(uint256,uint256)", eventId, 0)
        );
        require(sent, "Bet placement failed");
        vm.stopPrank();

        vm.warp(block.timestamp + 2 days); // Move past endTime
        vm.startPrank(owner);
        contractInstance.resolveEvent(eventId, "Real Madrid");
        vm.stopPrank();

        uint256 initialBalance = user1.balance;
        vm.startPrank(user1);
        contractInstance.claimWinnings(eventId);
        vm.stopPrank();

        // Check if user received payout (1 ether * 2 odds = 2 ether)
        uint256 finalBalance = user1.balance;
        assertEq(finalBalance - initialBalance, 2 ether, "Payout amount mismatch");
    }

    // Test edge case: Cannot bet after event end time
    function testCannotBetAfterEndTime() public {
        uint256 eventId = _createSampleEvent();
        vm.warp(block.timestamp + 2 days); // Move past endTime

        vm.startPrank(user1);
        vm.expectRevert("Betting period closed");
        (bool sent, ) = address(contractInstance).call{value: 1 ether}(
            abi.encodeWithSignature("placeBet(uint256,uint256)", eventId, 0)
        );
        vm.stopPrank();
    }

    // Test edge case: Cannot resolve event before end time
    function testCannotResolveBeforeEndTime() public {
        uint256 eventId = _createSampleEvent();

        vm.startPrank(owner);
        vm.expectRevert("Betting period not closed");
        contractInstance.resolveEvent(eventId, "Real Madrid");
        vm.stopPrank();
    }

    // Test security: Only owner can create events
    function testOnlyOwnerCanCreateEvent() public {
        vm.startPrank(user1);
        string memory eventName = "Test Event";
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Outcome1";
        outcomes[1] = "Outcome2";
        uint256[] memory odds = new uint256[](2);
        odds[0] = 2;
        odds[1] = 2;
        uint256 endTime = block.timestamp + 1 days;

        vm.expectRevert("Not the owner");
        contractInstance.createEvent(eventName, outcomes, odds, endTime);
        vm.stopPrank();
    }

    // Helper function to create a sample event
    function _createSampleEvent() private returns (uint256) {
        vm.startPrank(owner);
        string memory eventName = "Champions League Final: Real Madrid vs. Liverpool";
        string[] memory outcomes = new string[](3);
        outcomes[0] = "Real Madrid";
        outcomes[1] = "Liverpool";
        outcomes[2] = "Draw";
        uint256[] memory odds = new uint256[](3);
        odds[0] = 2; // 2:1 odds
        odds[1] = 2; // 2:1 odds
        odds[2] = 3; // 3:1 odds
        uint256 endTime = block.timestamp + 1 days;

        contractInstance.createEvent(eventName, outcomes, odds, endTime);
        uint256 eventId = contractInstance.eventCount() - 1;
        vm.stopPrank();
        return eventId;
    }

    // Test gas usage for key functions (optional, for optimization analysis)
    function testGasUsagePlaceBet() public {
        uint256 eventId = _createSampleEvent();
        vm.startPrank(user1);
        uint256 gasBefore = gasleft();
        (bool sent, ) = address(contractInstance).call{value: 1 ether}(
            abi.encodeWithSignature("placeBet(uint256,uint256)", eventId, 0)
        );
        require(sent, "Bet placement failed");
        uint256 gasAfter = gasleft();
        console.log("Gas used for placeBet:", gasBefore - gasAfter);
        vm.stopPrank();
    }
}