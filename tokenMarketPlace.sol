pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol"; // To console output

abstract contract TokenMarketPlace is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256; // x.add(y) = x+y

    uint256 public tokenPrice = 2e16 wei; // 0.02 ether per GLD token
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

    constructor(address _gldToken) Ownable(msg.sender) {
        gldToken = IERC20(_gldToken);
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
                .mul(1e18.sub(demandFactor))
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

        uint256 totalEarned = amountOfToken.mul(tokenPrice).div(1e18);

        // Transfer tokens from seller to the contract
        gldToken.safeTransferFrom(msg.sender, address(this), amountOfToken);

        // Pay Ether to the seller
        payable(msg.sender).transfer(totalEarned);

        // Adjust seller count
        sellerCount = sellerCount.add(1);

        // Adjust token price based on demand
        adjustTokenPriceBasedOnDemand();

        emit TokenSold(msg.sender, amountOfToken, totalEarned);
    }

    // Calculate the price for a specific token amount
    function calculateTokenPrice(uint256 _amountOfToken) public {
        require(
            _amountOfToken > 0,
            "Amount of Token must be greater than zero"
        );
        adjustTokenPriceBasedOnDemand();
        uint256 amountToPay = _amountOfToken.mul(tokenPrice).div(1e18);
        console.log("amountToPay", amountToPay);
    }

    // Owner can withdraw excess tokens from the contract
    function withdrawTokens(uint256 amount) public onlyOwner {
        gldToken.safeTransfer(msg.sender, amount);
        emit TokensWithdrawn(msg.sender, amount);
    }

    // Owner can withdraw accumulated Ether from the contract
    function withdrawEther(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
        emit EtherWithdrawn(msg.sender, amount);
    }
}
