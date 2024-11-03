// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract simpleWallet {
    address public owner;
    string public str;
    bool public paused;

    // Thresholds for detecting suspicious activities
    uint constant largeTransactionThreshold = 100 ether;
    uint constant smallTransactionThreshold = 0.01 ether;
    uint constant suspiciousTransactionInterval = 1 minutes;

    // Struct to store transaction details along with block timestamp
    struct Transaction {
        address from;
        address to;
        uint amount;
        uint txId;
        uint timestamp; // Add block timestamp to record the time of the transaction
    }

    // Struct to store suspicious activity
    struct SuspiciousActivity {
        address suspiciousAddress;
        uint amount;
        uint timestamp;
        string reason;
    }

    // Arrays to store transaction history and suspicious activities
    Transaction[] public transactions;
    SuspiciousActivity[] public suspiciousActivities;

    // Mapping to track the last transaction timestamp per address
    mapping(address => uint) public lastTransactionTimestamp;

    // Events to track transfers, receipts, and suspicious activity
    event Transfer(address indexed recipient, uint amount);
    event Receive(address indexed sender, uint amount);
    event TransactionRecorded(
        address indexed from,
        address indexed to,
        uint amount,
        uint txId,
        uint timestamp
    );
    event SuspiciousActivityLogged(
        address indexed suspiciousAddress,
        uint amount,
        string reason
    );

    // Constructor sets the contract deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Returns the contract balance in Wei.
     * @return The balance of the contract.
     */
    function getContractBalanceInWei() public view returns (uint) {
        return address(this).balance;
    }

    /**
     * @dev Transfers ether from the contract to a specified address.
     * @param _to The address to which Ether will be transferred.
     * @param _weiAmount The amount of Ether to transfer in Wei.
     */
    function transferToAddressViaContract(
        address payable _to,
        uint _weiAmount
    )
        external
        payable
        isOwner
        isSufficientBalance(_weiAmount)
        isValidAddress(_to)
    {
        _to.transfer(_weiAmount);
        addTransactionToHistory(_to, _weiAmount); // Add to transaction history
        checkForSuspiciousActivity(_to, _weiAmount); // Check for suspicious activity
        emit Transfer(_to, _weiAmount);
    }

    /**
     * @dev Withdraws ether from the contract to the owner's account.
     * @param amount The amount of Ether to withdraw in Wei.
     */
    function withdrawFromContract(
        uint amount
    ) external isOwner isSufficientBalance(amount) {
        payable(owner).transfer(amount);
        addTransactionToHistory(owner, amount); // Add to transaction history
        checkForSuspiciousActivity(owner, amount); // Check for suspicious activity
        emit Transfer(owner, amount);
    }

    /**
     * @dev Transfers ether directly from the owner to a specified address.
     * @param _to The address to transfer Ether to.
     */
    function transferToAddressDirectly(
        address payable _to
    )
        external
        payable
        isOwner
        isOwnerHaveSufficientBalance(msg.value)
        isValidAddress(_to)
    {
        _to.transfer(msg.value);
        addTransactionToHistory(_to, msg.value); // Add to transaction history
        checkForSuspiciousActivity(_to, msg.value); // Check for suspicious activity
        emit Transfer(_to, msg.value);
    }

    /**
     * @dev Adds a transaction to the transaction history.
     * @param _to The recipient address.
     * @param _amount The amount of Ether transferred.
     */
    function addTransactionToHistory(address _to, uint _amount) internal {
        transactions.push(
            Transaction({
                from: msg.sender,
                to: _to,
                amount: _amount,
                txId: transactions.length,
                timestamp: block.timestamp // Store block timestamp in transaction history
            })
        );
        emit TransactionRecorded(
            msg.sender,
            _to,
            _amount,
            transactions.length,
            block.timestamp
        ); // Emit an event for transaction with timestamp
    }

    /**
     * @dev Logs suspicious activity.
     * @param _suspiciousAddress The address involved in the suspicious activity.
     * @param _amount The amount involved.
     * @param _reason The reason for marking it as suspicious.
     */
    function logSuspiciousActivity(
        address _suspiciousAddress,
        uint _amount,
        string memory _reason
    ) internal {
        suspiciousActivities.push(
            SuspiciousActivity({
                suspiciousAddress: _suspiciousAddress,
                amount: _amount,
                timestamp: block.timestamp,
                reason: _reason
            })
        );
        emit SuspiciousActivityLogged(_suspiciousAddress, _amount, _reason);
    }

    /**
     * @dev Checks if a transaction is suspicious based on predefined criteria.
     * Logs the activity if found suspicious.
     * @param _to The address to check.
     * @param _amount The amount involved in the transaction.
     */
    function checkForSuspiciousActivity(address _to, uint _amount) internal {
        // Detect large transactions
        if (_amount >= largeTransactionThreshold) {
            logSuspiciousActivity(_to, _amount, "Large transaction");
        }

        // Detect multiple small transactions within a short interval
        uint lastTimestamp = lastTransactionTimestamp[_to];
        if (
            _amount <= smallTransactionThreshold &&
            (block.timestamp - lastTimestamp) <= suspiciousTransactionInterval
        ) {
            logSuspiciousActivity(
                _to,
                _amount,
                "Multiple small transactions in short interval"
            );
        }

        // Update the last transaction timestamp
        lastTransactionTimestamp[_to] = block.timestamp;
    }

    /**
     * @dev Receives ether and transfers it to the owner's account.
     * @notice Use this function to send Ether to the owner's account directly.
     */
    function receiveFromUserInOwnerAccount()
        external
        payable
        isPostiveValue(msg.value)
    {
        emit Receive(msg.sender, msg.value);
        payable(owner).transfer(msg.value);
        addTransactionToHistory(owner, msg.value); // Add to transaction history
        checkForSuspiciousActivity(owner, msg.value); // Check for suspicious activity
    }

    /**
     * @dev Receives ether and transfers it to the contract.
     * @notice Use this function to send Ether to the contract's balance.
     */
    function receiveFromUserToContract()
        external
        payable
        isPostiveValue(msg.value)
    {
        payable(address(this)).transfer(msg.value);
        addTransactionToHistory(address(this), msg.value); // Add to transaction history
        checkForSuspiciousActivity(address(this), msg.value); // Check for suspicious activity
        emit Receive(msg.sender, msg.value);
    }

    /**
     * @dev Retrieves all transaction history in one call.
     * @return An array of Transaction structs containing transaction details.
     */
    function getAllTransactionHistory()
        public
        view
        returns (Transaction[] memory)
    {
        return transactions;
    }

    /**
     * @dev Retrieves all suspicious activities in one call.
     * @return An array of SuspiciousActivity structs containing suspicious activities details.
     */
    function getAllSuspiciousActivities()
        public
        view
        returns (SuspiciousActivity[] memory)
    {
        return suspiciousActivities;
    }

    /**
     * @dev changes the owner of smart contract
     * @param _newOwner The address of the new owner
     */
    function changeOwner(
        address _newOwner
    ) external isOwner isValidAddress(_newOwner) {
        owner = _newOwner;
    }

    /**
     * @dev function to toggle the contract's state
     */
    function toggleStop() external isOwner {
        paused = !paused;
    }

    /**
     * @dev function to withdraw all funds at once in case of emergency
     */
    function withdrawAllFunds() external isOwner {
        require(paused, "Contract is not paused");
        payable(owner).transfer(address(this).balance);
    }

    /**
     * @dev Fallback function to receive Ether when no data is provided.
     * This will store the message in `str` and transfer Ether to the contract.
     */
    fallback() external payable {
        str = "This is default fallback function";
        emit Receive(msg.sender, msg.value);
        addTransactionToHistory(address(this), msg.value); // Add to transaction history for fallback
        checkForSuspiciousActivity(address(this), msg.value); // Check for suspicious activity
    }

    /**
     * @dev Function to receive Ether into the contract when Ether is sent without any function call.
     * This is a specific function to handle receiving Ether.
     */
    receive() external payable {
        emit Receive(msg.sender, msg.value);
        addTransactionToHistory(address(this), msg.value); // Add to transaction history for receiving Ether
        checkForSuspiciousActivity(address(this), msg.value); // Check for suspicious activity
    }

    // Modifiers

    /**
     * @dev Modifier to check if the caller is the owner of the contract.
     */
    modifier isOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    /**
     * @dev Modifier to check if the contract has enough balance for a transfer.
     * @param amount The amount of Ether to check against the contract's balance.
     */
    modifier isSufficientBalance(uint amount) {
        require(address(this).balance >= amount, "Insufficient balance");
        _;
    }

    /**
     * @dev Modifier to check if the owner's account has sufficient balance.
     * @param amount The amount of Ether to check against the owner's balance.
     */
    modifier isOwnerHaveSufficientBalance(uint amount) {
        require(owner.balance >= amount, "Owner has insufficient balance");
        _;
    }

    /**
     * @dev Modifier to check if the value provided is positive.
     * @param _value The value to check.
     */
    modifier isPostiveValue(uint _value) {
        require(_value > 0, "Value is not positive");
        _;
    }

    /**
     * @dev Modifier to check if the provided address is valid (non-zero address).
     * @param _address The address to validate.
     */
    modifier isValidAddress(address _address) {
        require(_address != address(0), "Invalid address: zero address");
        _;
    }
}
