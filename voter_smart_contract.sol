// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract Vote {
    constructor() {
        electionCommission = msg.sender;
    }
    //1st entity
    struct Voter {
        string name;
        uint age;
        uint voterId;
        Gender gender;
        uint voterCandidateId;
        address voterAddress;
    }

    //2nd entity
    struct Candidate {
        string name;
        uint party;
        uint age;
        Gender gender;
        uint candidateId;
        address candidateAddress; //candidate EOA
        uint voteCount;
    }

    //3rd entity
    address public electionCommission;

    address public winner;
    uint nextVoterId = 1;
    uint nextCandidateId = 1;

    //voting period
    uint startTime;
    uint endTime;
    bool stopVoting;

    mapping(uint => Voter) public voterDetails;
    mapping(uint => Candidate) public candidateDetails;

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

    modifier isVotingOver() {
        require(
            block.timestamp <= endTime && stopVoting == false,
            "Voting is over"
        );
        _;
    }
    modifier checkIfElectionCommission() {
        require(msg.sender == electionCommission, "Not Authorized");
        _;
    }

    modifier isElectionCommission() {
        require(msg.sender == electionCommission, "Not Authorized");
        _;
    }
    function emergencyStopVoting() public checkIfElectionCommission {
        stopVoting = true;
    }

    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint _age,
        Gender _gender
    )
        external
        checkIfElectionCommission
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

    function isVoterEligible(uint _voterId) public view returns (bool) {
        if (voterDetails[_voterId].age >= 18) {
            return true;
        } else {
            return false;
        }
    }
    modifier isAgeValid(uint _age) {
        require(_age >= 18, "Age should be greater than 18");
        _;
    }
    modifier isVoterAlreadyRegistered(address _voterAddress) {
        require(
            voterDetails[nextVoterId].voterAddress != _voterAddress,
            "Voter already registered"
        );
        _;
    }
    modifier isCandidateAlreadyRegistered(address _candidateAddress) {
        require(
            candidateDetails[nextCandidateId].candidateAddress !=
                _candidateAddress,
            "Candidate already registered"
        );
        _;
    }
    modifier isCandidateLimitReached() {
        require(nextCandidateId <= 3, "Candidate limit reached");
        _;
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
    function getVoterList() public view returns (Voter[] memory) {
        Voter[] memory voters = new Voter[](nextVoterId - 1);
        for (uint i = 1; i < nextVoterId; i++) {
            voters[i] = voterDetails[i];
        }
        return voters;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
        Candidate[] memory candidates = new Candidate[](nextCandidateId - 1);
        for (uint i = 1; i < nextCandidateId; i++) {
            candidates[i] = candidateDetails[i];
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
        require(_candidateId >= 1 && _candidateId <= 3, "Invalid Candidate Id");
        voterDetails[_voterId].voterCandidateId = _candidateId;
        candidateDetails[_candidateId].voteCount++;
        return "Voted Successfully";
    }

    function setVotingPeriod(
        uint _startTime,
        uint _endTime
    ) public isElectionCommission {
        startTime = _startTime;
        endTime = _endTime;
    }
    function getVotingStatus() public view returns (votingStatus) {
        if (block.timestamp < startTime) {
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
