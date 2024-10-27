// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

//learning inheritance

contract Car{
    uint public wheels;
    uint public price;
    uint public doors;
    string public color;
    string public brandName;
    uint public headlight;
}

contract Audi is Car{
    constructor(uint _wheels, uint _price, uint _doors, string memory _color, string memory _brandName, uint _headlight){
        wheels = _wheels;
        price = _price;
        doors = _doors;
        color = _color;
        brandName = _brandName;
        headlight = _headlight;
    }
}