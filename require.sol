// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

contract InputChecker {
    // Function to check if the input is within the valid range (0 to 255)
    function checkInput(uint input) public pure returns (string memory) {
        require(input >= 0 && input <= 255, "Not Within Range");
        return "Within Range";
    }
}
