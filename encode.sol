// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transfer(address, uint256) external;
}
event TransferDecoded(address indexed to, uint256 amount);
contract Token {
    function transfer(address, uint256) external {
        // Extract the calldata excluding the function selector (first 4 bytes)
        bytes memory data = msg.data[4:];

        // Decode the parameters
        (address to, uint256 amount) = abi.decode(data, (address, uint256));

        // Now you can use the `to` and `amount` variables as needed
        // For demonstration, we'll just log the values (assuming an event is defined for logging)
        emit TransferDecoded(to, amount);
    }
}

contract AbiEncode {
    function callTokenContractFunction(
        address _contract,
        bytes calldata data
    ) external {
        (bool ok, ) = _contract.call(data);
        require(ok, "transaction failed");
    }

    function encodeWithSignature(
        address to,
        uint256 amount
    ) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function encodeWithSelector(
        address to,
        uint256 amount
    ) external pure returns (bytes memory) {
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    function encodeCall(
        address to,
        uint256 amount
    ) external pure returns (bytes memory) {
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }
}
