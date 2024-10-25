// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

library MathsLibrary{
    function add(uint a, uint b) internal pure returns(uint){
        return a + b;
    }

    function sub(uint a, uint b) internal pure returns(uint){
        return a - b;
    }

    function mul(uint a, uint b) internal pure returns(uint){
        return a * b;
    }

    function div(uint a, uint b) internal pure returns(uint){
        return a / b;
    }
}
contract embeddedLibrary {
    constructor(){

    }
    function add(uint a, uint b) external pure returns(uint){
        return MathsLibrary.add(a, b);
    }
}
