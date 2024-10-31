// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface interfaceContract{
    function add(uint a, uint b) external pure returns(uint);
    function sub(uint a, uint b) external pure returns(uint);
    function mul(uint a, uint b) external pure returns(uint);
    function div(uint a, uint b) external pure returns(uint);
}

contract interfaceContractImplementation is interfaceContract{
    constructor(){

    }
    function add(uint a, uint b) external pure override returns(uint){
        return a + b;
    }
    function sub(uint a, uint b) external pure override returns(uint){
        return a - b;
    }
    function mul(uint a, uint b) external pure override returns(uint){
        return a * b;
    }
    function div(uint a, uint b) external pure override returns(uint){
        return a / b;
    }
}