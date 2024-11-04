// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract Alice {
    uint256 public x;
    address public value;
    constructor() {}
    function setter(uint256 _x) public {
        x = _x;
    }
    function getter() public view returns (uint256) {
        return x;
    }
    function payableSetter(uint256 _x) public payable {
        x = _x;
        value = msg.sender;
    }
}

contract Bob {
    constructor() {}

    function getStateVariable(
        Alice _aliceAddress
    ) public view returns (uint256) {
        return _aliceAddress.getter();
    }

    function setStateVariable(Alice _aliceAddress, uint256 _y) public {
        _aliceAddress.setter(_y);
    }

    function setPayableStateVariable(
        Alice _aliceAddress,
        uint256 _y
    ) public payable {
        _aliceAddress.payableSetter{value: msg.value}(_y);
    }
}
