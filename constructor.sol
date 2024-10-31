// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

abstract contract Parent{
    string public str;
    address public owner;

    constructor(){
        str ="Hello World";
        owner = msg.sender;
    }
    function setter(string memory _str) public virtual;
    function getter() public view virtual returns(string memory);
}

contract Child is Parent{
    uint public num;
    constructor(){
        num = 5;
    }
    function setter(string memory _str) public override{
        str = _str;
    }
    function getter() public view override returns(string memory){
        return str;
    }
}