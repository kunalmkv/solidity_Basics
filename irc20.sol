// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when value tokens are moved from one account (from) to
     * another (to).
     *
     * Note that value may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a spender for an owner is set by
     * a call to {approve}. value is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by account.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a value amount of tokens from the caller's account to to.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that spender will be
     * allowed to spend on behalf of owner through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets a value amount of tokens as the allowance of spender over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a value amount of tokens from from to to using the
     * allowance mechanism. value is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
contract KunalErc20 is IERC20 {
    address public founder;
    uint public totalSupply = 1000;
    mapping(address => uint) public balanceOfUsers;
    mapping(address => mapping(address => uint)) public allowances;

    constructor() {
        founder = msg.sender;
        balanceOfUsers[founder] = totalSupply;
    }

    // Modifiers
    modifier onlyValidAddress(address account) {
        require(account != address(0), "Invalid address");
        _;
    }

    modifier hasSufficientBalance(address account, uint256 amount) {
        require(balanceOfUsers[account] >= amount, "Insufficient balance");
        _;
    }

    modifier hasSufficientAllowance(
        address owner,
        address spender,
        uint256 amount
    ) {
        require(allowances[owner][spender] >= amount, "Insufficient allowance");
        _;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return balanceOfUsers[account];
    }

    function transfer(
        address to,
        uint256 value
    )
        public
        virtual
        override
        onlyValidAddress(to)
        hasSufficientBalance(msg.sender, value)
        returns (bool)
    {
        balanceOfUsers[msg.sender] -= value;
        balanceOfUsers[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        virtual
        override
        onlyValidAddress(to)
        onlyValidAddress(from)
        hasSufficientBalance(from, value)
        hasSufficientAllowance(from, msg.sender, value)
        returns (bool)
    {
        balanceOfUsers[from] -= value;
        balanceOfUsers[to] += value;
        allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(
        address spender,
        uint256 value
    )
        public
        virtual
        override
        onlyValidAddress(spender)
        hasSufficientBalance(msg.sender, value)
        returns (bool)
    {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return allowances[owner][spender];
    }
}
