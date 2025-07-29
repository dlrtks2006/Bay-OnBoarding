// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint256 votedAt;
    }

    // Fixed list of 5 candidates
    Candidate[] public candidates = [
        Candidate({name: "Candidate 1", voteCount: 0}),
        Candidate({name: "Candidate 2", voteCount: 0}),
        Candidate({name: "Candidate 3", voteCount: 0}),
        Candidate({name: "Candidate 4", voteCount: 0}),
        Candidate({name: "Candidate 5", voteCount: 0})
    ];

    // Mapping to manage votes and voters
    mapping(address => Voter) public voters;
    mapping(address => uint256) public candidateVotes;

    // Timing variables
    uint256 public startTime;
    uint256 public endTime;
    uint256 public constant VOTING_DURATION = 7 days; // Example: 7 days voting period
    uint256 public constant TIMELOCK_DURATION = 1 hours; // Example: 1 hour timelock

    // Events
    event VoteCast(address indexed voter, uint256 candidateIndex, uint256 timestamp);

    // Modifiers
    modifier onlyAfterTimelock() {
        require(block.timestamp >= startTime + TIMELOCK_DURATION, "Voting has not started yet");
        _;
    }

    modifier onlyBeforeEndTime() {
        require(block.timestamp < endTime, "Voting has ended");
        _;
    }

    modifier hasNotVoted(address _voter) {
        require(!voters[_voter].hasVoted, "You have already voted");
        _;
    }

    constructor() {
        startTime = block.timestamp;
        endTime = startTime + VOTING_DURATION;
    }

    // Vote function
    function vote(uint256 candidateIndex) external onlyAfterTimelock onlyBeforeEndTime {
        require(candidateIndex < candidates.length, "Invalid candidate index");

        _vote(msg.sender, candidateIndex);
    }

    function _vote(address _voter, uint256 candidateIndex) internal hasNotVoted(_voter) {
        voters[_voter].hasVoted = true;
        voters[_voter].votedAt = block.timestamp;
        candidates[candidateIndex].voteCount++;

        emit VoteCast(_voter, candidateIndex, block.timestamp);
    }

    // Function to check if voting has started
    function hasVotingStarted() public view returns (bool) {
        return block.timestamp >= startTime + TIMELOCK_DURATION;
    }

    // Function to check if voting has ended
    function hasVotingEnded() public view returns (bool) {
        return block.timestamp >= endTime;
    }

    // Function to get the remaining time for voting
    function getRemainingTime() public view returns (uint256) {
        if (block.timestamp < startTime + TIMELOCK_DURATION) {
            return startTime + TIMELOCK_DURATION - block.timestamp;
        } else if (block.timestamp < endTime) {
            return endTime - block.timestamp;
        } else {
            return 0;
        }
    }
}