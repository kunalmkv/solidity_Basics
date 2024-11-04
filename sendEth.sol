// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract sendEth {
    constructor(){

    }

    function sendEther(address payable _to) external payable {
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function callEther(address payable _to) external payable {
        (bool sent, bytes memory data ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
        return (sent , data);
    }

    function transferEther(address payable _to) external payable {
        _to.transfer(msg.value);
    }
}
