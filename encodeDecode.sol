// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract encodeDecode {
    constructor() {}

    function encodeData(
        uint256 fixedNumber,
        string memory dynamicString,
        uint256[2] memory fixedArray,
        uint256[] memory dynamicArray
    ) public pure returns (bytes memory) {
        return abi.encode(fixedNumber, dynamicString, fixedArray, dynamicArray);
    }
    function decodeData(
        bytes memory data
    )
        public
        pure
        returns (uint256, string memory, uint256[2] memory, uint256[] memory)
    {
        return abi.decode(data, (uint256, string, uint256[2], uint256[]));
    }
}
