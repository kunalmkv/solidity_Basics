// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract Vote {
    constructor() {
        electionCommission = msg.sender;
    }

    // Structs
    struct Voter {
        string name;
        uint age;
        uint voterId;
        Gender gender;
        uint voterCandidateId;
        address voterAddress;
    }

    struct Candidate {
        string name;
        string party; // Changed from uint to string
        uint age;
        Gender gender;
        uint candidateId;
        address candidateAddress;
        uint voteCount;
    }

    // State Variables
    address public electionCommission;
    address public winner;
    uint public nextVoterId = 1;
    uint public nextCandidateId = 1;

    uint public startTime;
    uint public endTime;
    bool public stopVoting;
    string public emergencyReason;
    bool public isEmergencyDeclared;
    uint public candidateLimit = 3; // Added candidate limit as a configurable variable

    mapping(uint => Voter) public voterDetails;
    mapping(uint => Candidate) public candidateDetails;

    // Enums
    enum votingStatus {
        NOT_STARTED,
        STARTED,
        STOPPED
    }

    enum Gender {
        MALE,
        FEMALE,
        OTHER,
        NOT_SPECIFIED
    }

    // Modifiers
    modifier isVotingOver() {
        require(
            block.timestamp <= endTime && stopVoting == false,
            "Voting is over"
        );
        _;
    }

    modifier isElectionCommission() {
        require(msg.sender == electionCommission, "Not Authorized");
        _;
    }

    modifier isAgeValid(uint _age) {
        require(_age >= 18, "Age should be greater than 18");
        _;
    }

    modifier isVoterAlreadyRegistered(address _voterAddress) {
        for (uint i = 1; i < nextVoterId; i++) {
            require(
                voterDetails[i].voterAddress != _voterAddress,
                "Voter already registered"
            );
        }
        _;
    }

    modifier isCandidateAlreadyRegistered(address _candidateAddress) {
        for (uint i = 1; i < nextCandidateId; i++) {
            require(
                candidateDetails[i].candidateAddress != _candidateAddress,
                "Candidate already registered"
            );
        }
        _;
    }

    modifier isCandidateLimitReached() {
        require(nextCandidateId <= candidateLimit, "Candidate limit reached");
        _;
    }

    // Functions
    function emergencyStopVoting() public isElectionCommission {
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Voting is not active"
        );
        stopVoting = true;
    }

    function emergencyDeclare(
        string memory reason
    ) public isElectionCommission {
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Voting is not active"
        );
        require(!isEmergencyDeclared, "Emergency already declared");
        stopVoting = true;
        isEmergencyDeclared = true;
        emergencyReason = reason;
    }

    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint _age,
        Gender _gender
    )
        external
        isElectionCommission
        isCandidateLimitReached
        isCandidateAlreadyRegistered(msg.sender)
    {
        candidateDetails[nextCandidateId] = Candidate({
            name: _name,
            party: _party,
            age: _age,
            gender: _gender,
            candidateId: nextCandidateId,
            candidateAddress: msg.sender,
            voteCount: 0
        });

        nextCandidateId++;
    }

    function registerVoter(
        string calldata _name,
        uint _age,
        uint _voterId,
        Gender _gender
    ) external isAgeValid(_age) isVoterAlreadyRegistered(msg.sender) {
        voterDetails[nextVoterId] = Voter({
            name: _name,
            age: _age,
            voterId: _voterId,
            gender: _gender,
            voterCandidateId: 0,
            voterAddress: msg.sender
        });
        nextVoterId++;
    }

    function setCandidateLimit(uint _limit) public isElectionCommission {
        candidateLimit = _limit;
    }

    function getVoterList() public view returns (Voter[] memory) {
        Voter[] memory voters = new Voter[](nextVoterId - 1);
        for (uint i = 1; i < nextVoterId; i++) {
            voters[i - 1] = voterDetails[i];
        }
        return voters;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
        Candidate[] memory candidates = new Candidate[](nextCandidateId - 1);
        for (uint i = 1; i < nextCandidateId; i++) {
            candidates[i - 1] = candidateDetails[i];
        }
        return candidates;
    }

    function castVote(
        uint _voterId,
        uint _candidateId
    ) external isVotingOver returns (string memory) {
        require(voterDetails[_voterId].voterCandidateId == 0, "Already Voted");
        require(
            candidateDetails[_candidateId].candidateId != 0,
            "Candidate not registered"
        );

        require(
            voterDetails[_voterId].voterAddress == msg.sender,
            "Not Authorized"
        );
        require(
            _candidateId >= 1 && _candidateId <= candidateLimit,
            "Invalid Candidate Id"
        );

        voterDetails[_voterId].voterCandidateId = _candidateId;
        candidateDetails[_candidateId].voteCount++;

        if (
            candidateDetails[_candidateId].voteCount >
            candidateDetails[nextCandidateId - 1].voteCount
        ) {
            winner = candidateDetails[_candidateId].candidateAddress;
        }

        return "Voted Successfully";
    }

    function setVotingPeriod(
        uint _startTime,
        uint _endTime
    ) public isElectionCommission {
        require(
            _startTime > block.timestamp,
            "Start time must be in the future"
        );
        require(_endTime > _startTime, "End time must be after start time");

        startTime = _startTime;
        endTime = _endTime;
    }

    function getVotingStatus() public view returns (votingStatus) {
        if (isEmergencyDeclared) {
            return votingStatus.STOPPED;
        } else if (block.timestamp < startTime) {
            return votingStatus.NOT_STARTED;
        } else if (block.timestamp >= startTime && block.timestamp <= endTime) {
            return votingStatus.STARTED;
        } else {
            return votingStatus.STOPPED;
        }
    }

    function announceWinner() public isElectionCommission {
        uint maxVotes = 0;
        for (uint i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].voteCount > maxVotes) {
                maxVotes = candidateDetails[i].voteCount;
                winner = candidateDetails[i].candidateAddress;
            }
        }
    }
}
