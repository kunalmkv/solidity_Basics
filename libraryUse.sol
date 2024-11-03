// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./library.sol";

contract sumFunc {
    function sumFunc(uint a, uint b) public pure returns (uint) {
        return Addition.add(a, b);
    }
}
