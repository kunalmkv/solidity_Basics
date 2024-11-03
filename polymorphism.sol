// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract polymorphism {
    constructor() {}

    function add(uint a, uint b) public pure returns (uint) {
        return a + b;
    }

    function add(uint a, uint b, uint c) public pure returns (uint) {
        return a + b + c;
    }

    function add(uint a, uint b, uint c, uint d) public pure returns (uint) {
        return a + b + c + d;
    }
}
