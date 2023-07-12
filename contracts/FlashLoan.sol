// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

contract FlashLoan { 
    using SafeMath for uint256;

    Token public token;
    uint256 public poolBalance;

    // store token address
    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
    }

    modifier atLeastOneToken(uint256 _amount) {
        require(_amount > 0, "Must deposit at least one token!");
        _;
    }

    //take tokens out of a persons wallet and put them into the pool
    function depositTokens(uint256 _amount) external atLeastOneToken(_amount) {
        token.transferFrom(msg.sender, address(this), _amount);
        poolBalance = poolBalance.add(_amount);
    }

    function flashLoan(uint256 _borrowAmount) external {
        require(_borrowAmount > 0, "Must borrow at least 1 token");

        //we must make sure that the flash loan is returned in full to the smart contract
        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= _borrowAmount, "Not enough tokens in pool");

        // Ensured by the protocol via the 'depositTokens' function
        assert(poolBalance == balanceBefore);

        // Send tokens to receiver
        // msg.sender is going to be the FlashLoanReceiver in this case, since we will call this function from there
        token.transfer(msg.sender, _borrowAmount);

        // Get paid back
        // msg.sender is the contract who is calling the flash loan, so they will be receiving the flash loan and tokens
        IReceiver(msg.sender).receiveTokens(address(token), _borrowAmount);
        
        // Ensure loan paid back
        
    }

}