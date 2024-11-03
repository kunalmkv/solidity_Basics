// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract storageTypes {
    constructor() {}

    uint[3] public fixedSizeArray = [1, 2, 3];

    function storageArray() external {
        uint[3] storage storageArray = fixedSizeArray;
        storageArray[0] = 10;
    }

    function memoryArray() external {
        uint[3] memory memoryArray = fixedSizeArray;
        memoryArray[0] = 100;
        return memoryArray;
    }
}
