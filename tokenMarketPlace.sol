// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenMarketPlace is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 public tokenPrice; // Token price initialized during deployment
    uint256 public sellerCount = 1;
    uint256 public buyerCount = 1;

    IERC20 public gldToken;

    event TokenPriceUpdated(uint256 newPrice);
    event TokenBought(address indexed buyer, uint256 amount, uint256 totalCost);
    event TokenSold(
        address indexed seller,
        uint256 amount,
        uint256 totalEarned
    );
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event EtherWithdrawn(address indexed owner, uint256 amount);
    event CalculateTokenPrice(uint256 priceToPay);

    constructor(
        address _gldToken,
        address _initialOwner,
        uint256 _initialPrice
    ) Ownable(_initialOwner) {
        require(_initialPrice > 0, "Initial price must be greater than zero");
        gldToken = IERC20(_gldToken);
        tokenPrice = _initialPrice; // Set the initial token price
    }

    // Adjust the token price based on demand and supply dynamics
    function adjustTokenPriceBasedOnDemand() public {
        uint256 demandFactor = buyerCount.mul(1e18).div(sellerCount);

        if (demandFactor > 1e18) {
            // If demand is higher, increase the price
            uint256 increment = tokenPrice
                .mul(demandFactor.sub(1e18))
                .div(1e18)
                .div(10); // 10% adjustment
            tokenPrice = tokenPrice.add(increment);
        } else if (demandFactor < 1e18) {
            // If supply is higher, decrease the price
            uint256 decrement = tokenPrice
                .mul(uint256(1e18).sub(demandFactor))
                .div(1e18)
                .div(10); // 10% adjustment
            if (decrement < tokenPrice) {
                tokenPrice = tokenPrice.sub(decrement);
            }
        }

        emit TokenPriceUpdated(tokenPrice);
    }

    // Buy tokens from the marketplace
    function buyGLDToken(uint256 _amountOfToken) public payable {
        require(_amountOfToken > 0, "Amount must be greater than zero");
        uint256 totalCost = _amountOfToken.mul(tokenPrice).div(1e18);
        require(msg.value >= totalCost, "Insufficient Ether sent");

        // Transfer tokens to the buyer
        gldToken.safeTransfer(msg.sender, _amountOfToken);

        // Adjust buyer count
        buyerCount = buyerCount.add(1);

        // Adjust token price based on demand
        adjustTokenPriceBasedOnDemand();

        emit TokenBought(msg.sender, _amountOfToken, totalCost);
    }

    // Sell tokens back to the marketplace
    function sellGLDToken(uint256 amountOfToken) public {
        require(amountOfToken > 0, "Amount must be greater than zero");
        require(
            gldToken.balanceOf(msg.sender) >= amountOfToken,
            "Insufficient token balance"
        );

        uint256 totalEarned = calculateTokenPrice(amountOfToken);

        // Ensure contract has enough Ether, top up if necessary
        if (address(this).balance < totalEarned) {
            uint256 requiredAmount = totalEarned.sub(address(this).balance);
            require(
                address(this).balance + requiredAmount >= totalEarned,
                "Owner failed to top up"
            );

            (bool topUpSuccess, ) = payable(address(this)).call{
                value: requiredAmount
            }("");
            require(topUpSuccess, "Top-up failed");
        }

        // Transfer tokens from seller to the contract
        gldToken.safeTransferFrom(msg.sender, address(this), amountOfToken);

        // Adjust seller count
        sellerCount = sellerCount.add(1);

        // Adjust token price based on demand
        adjustTokenPriceBasedOnDemand();

        // Transfer Ether to the seller
        (bool success, ) = payable(msg.sender).call{value: totalEarned}("");
        require(success, "Oops ! Transfer failed.");

        emit TokenSold(msg.sender, amountOfToken, totalEarned);
    }

    // Calculate the price for a specific token amount
    function calculateTokenPrice(
        uint256 _amountOfToken
    ) public view returns (uint256) {
        require(
            _amountOfToken > 0,
            "Amount of Token must be greater than zero"
        );
        uint256 amountToPay = _amountOfToken.mul(tokenPrice).div(1e18);
        return amountToPay;
    }

    // Owner can withdraw excess tokens from the contract
    function withdrawTokens(uint256 amount) public onlyOwner {
        require(
            gldToken.balanceOf(address(this)) >= amount,
            "Insufficient token balance"
        );
        gldToken.safeTransfer(msg.sender, amount);
        emit TokensWithdrawn(msg.sender, amount);
    }

    // Owner can withdraw accumulated Ether from the contract
    function withdrawEther(uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient Ether balance");
        payable(msg.sender).transfer(amount);
        emit EtherWithdrawn(msg.sender, amount);
    }

    // Allow contract to receive Ether
    receive() external payable {}
}
