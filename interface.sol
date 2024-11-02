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

contract interfaceUser{
    interfaceContract interfaceContractInstance = new interfaceContractImplementation();
    function add(uint a, uint b) external pure returns(uint){
        return interfaceContractInstance.add(a, b);
    }
    function sub(uint a, uint b) external pure returns(uint){
        return interfaceContractInstance.sub(a, b);
    }
    function mul(uint a, uint b) external pure returns(uint){
        return interfaceContractInstance.mul(a, b);
    }
    function div(uint a, uint b) external pure returns(uint){
        return interfaceContractInstance.div(a, b);
    }
}

//or it can be directly accessed through interface address

contract interfaceUser2{
   function add(address interfaceAddress, uint a, uint b) external pure returns(uint){
        return interfaceContract(interfaceAddress).add(a, b);
    }
    function sub(address interfaceAddress, uint a, uint b) external pure returns(uint){
        return interfaceContract(interfaceAddress).sub(a, b);
    }
    function mul(address interfaceAddress, uint a, uint b) external pure returns(uint){
        return interfaceContract(interfaceAddress).mul(a, b);
    }
    function div(address interfaceAddress, uint a, uint b) external pure returns(uint){
        return interfaceContract(interfaceAddress).div(a, b);
    }
}