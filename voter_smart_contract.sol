// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract Vote {
    uint public maxVotes = 0;
    constructor() {
        electionCommission = msg.sender;
    }

    Voter[] public voterList;
    Candidate[] public candidateList;
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
    mapping(address => bool) public hasVoted;
    mapping(address => bool) public isVoterRegistered;
    mapping(address => bool) public isCandidateRegistered;

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
    event VoterRegistered(
        string name,
        uint age,
        uint voterId,
        Gender gender,
        address voterAddress
    );

    modifier isElectionCommission() {
        require(msg.sender == electionCommission, "Not Authorized");
        _;
    }

    modifier isAgeValid(uint _age) {
        require(_age >= 18, "Age should be greater than 18");
        _;
    }

    modifier isCandidateLimitReached() {
        require(nextCandidateId <= candidateLimit, "Candidate limit reached");
        _;
    }

    modifier isVoterAlreadyRegistered() {
        require(!isVoterRegistered[msg.sender], "Voter already registered");
        _;
    }

    modifier isCandidateAlreadyRegistered(address _candidateAddress) {
        require(
            !isCandidateRegistered[_candidateAddress],
            "Candidate already registered"
        );
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
    //helper functions
    function uintToString(uint _num) internal pure returns (string memory) {
        if (_num == 0) {
            return "0";
        }
        uint i = _num;
        uint length;
        while (i != 0) {
            length++;
            i /= 10;
        }
        bytes memory buffer = new bytes(length);
        while (_num != 0) {
            length -= 1;
            buffer[length] = bytes1(uint8(48 + _num % 10));
            _num /= 10;
        }
        return string(buffer);
    }

    function addressToString(address _addr) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes20 value = bytes20(_addr);
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i] & 0x0f)];
        }
        return string(str);
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
        address _candidateAddress,
        string calldata _name,
        string calldata _party,
        uint _age,
        Gender _gender
    )
    external
    isElectionCommission
    isCandidateLimitReached
    isCandidateAlreadyRegistered(_candidateAddress)
    {
        Candidate memory newCandidate = Candidate({
            name: _name,
            party: _party,
            age: _age,
            gender: _gender,
            candidateId: nextCandidateId,
            candidateAddress: _candidateAddress,
            voteCount: 0
        });

        candidateDetails[nextCandidateId] = newCandidate;
        candidateList.push(newCandidate);
        isCandidateRegistered[msg.sender] = true;
        nextCandidateId++;
    }
    function updateCandidateLimit(uint _limit) public isElectionCommission {
        require(
            nextCandidateId == 1,
            "Cannot change limit after registration starts"
        );
        candidateLimit = _limit;
    }

    function resetElection() public isElectionCommission {
        require(block.timestamp > endTime, "Election not over yet");

        for (uint i = 1; i < nextVoterId; i++) {
            delete voterDetails[i];
        }
        for (uint i = 1; i < nextCandidateId; i++) {
            delete candidateDetails[i];
        }
        nextVoterId = 1;
        nextCandidateId = 1;
        winner = address(0);
        stopVoting = false;
        isEmergencyDeclared = false;
    }

    function registerVoter(
        string calldata _name,
        uint _age,
        uint _voterId,
        Gender _gender
    ) external isAgeValid(_age) isVoterAlreadyRegistered {
        Voter memory newVoter = Voter({
            name: _name,
            age: _age,
            voterId: _voterId,
            gender: _gender,
            voterCandidateId: 0,
            voterAddress: msg.sender
        });

        voterDetails[nextVoterId] = newVoter;
        voterList.push(newVoter);
        isVoterRegistered[msg.sender] = true;
        nextVoterId++;
    }

    function setCandidateLimit(uint _limit) public isElectionCommission {
        candidateLimit = _limit;
    }

    function getVoterList() public view returns (Voter[] memory) {
        return voterList;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
        return candidateList;
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

        require(voterDetails[_voterId].voterAddress == msg.sender,
            string(abi.encodePacked(
                "Unauthorized: msg.sender (", addressToString(msg.sender),
                ") does not match registered voter (", addressToString(voterDetails[_voterId].voterAddress), ")"
            )));

        require(
            _candidateId >= 1 && _candidateId <= candidateLimit,
            "Invalid Candidate Id"
        );
        require(!isEmergencyDeclared, "Emergency declared, voting stopped");
        require(!hasVoted[msg.sender], "Already voted");
        hasVoted[msg.sender] = true;

        voterDetails[_voterId].voterCandidateId = _candidateId;
        candidateDetails[_candidateId].voteCount++;

        if (candidateDetails[_candidateId].voteCount > maxVotes) {
            maxVotes = candidateDetails[_candidateId].voteCount;
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
    function withdrawFunds() public isElectionCommission {
        payable(electionCommission).transfer(address(this).balance);
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

    function announceWinner()
    public
    view
    isElectionCommission
    returns (address, uint)
    {
        require(block.timestamp > endTime, "Voting is still active");
        require(winner != address(0), "No votes cast yet");
        return (winner, maxVotes);
    }
}