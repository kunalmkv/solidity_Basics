// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract simpleWallet {
    address public owner;
    string public str;
    constructor() {
        owner = msg.sender;
    }
    function getContractBalanceInWei() public view returns (uint) {
        return address(this).balance;
    }
    function transferToContract() public payable {}

    modifier isOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    modifier isSufficientBalance(uint amount) {
        require(address(this).balance >= amount, "Insufficient balance");
        _;
    }
    modifier isOwnerHaveSufficientBalance(uint amount) {
        require(owner.balance >= amount, "Owner has insufficient balance");
        _;
    }

    modifier isPostiveValue(uint _value) {
        require(_value > 0, "Value is not positive");
        _;
    }
    function transferToAddressViaContract(
        address payable _to,
        uint _weiAmount
    ) external payable isOwner isSufficientBalance(_weiAmount) {
        _to.transfer(_weiAmount);
    }

    function withdrawFromContract(uint amount) external isOwner isSufficientBalance(amount) {

    }
    function transferToAddressDirectly(address payable _to, uint) external payable isOwner isOwnerHaveSufficientBalance(msg.value) {
        _to.transfer(msg.value);
    }

    function receiveFromUserInOwnerAccount()  external payable isPostiveValue(msg.value)   {
        payable(owner).transfer(msg.value);

    }

    function receiveFromUserToContract() external payable isPostiveValue(msg.value)   {
        payable(address(this)).transfer(msg.value);

    }

    fallback() external {
        str= "This is default fallback function";
    }
}

//npx prettier --write --plugin=prettier-plugin-solidity 'contracts/**/*.sol'