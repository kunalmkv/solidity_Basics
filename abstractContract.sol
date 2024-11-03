// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

abstract contract abstractContract {
    constructor() {
        str = "Hello world";
        manager = msg.sender;
    }
    string public str;
    address public manager;
    function abstractFunc() public pure virtual returns (uint);
}

contract concreteContract is abstractContract {
    constructor() {}
    function abstractFunc() public pure override returns (uint) {
        return 10;
    }
}
