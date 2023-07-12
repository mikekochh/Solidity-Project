// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./FlashLoan.sol";

contract FlashLoanReceiver { 
    FlashLoan private pool;
    address private owner;

    event LoanReceived(address token, uint256 amount);

    constructor(address _poolAddress) {
        pool = FlashLoan(_poolAddress);
        owner = msg.sender;
    }

    function executeFlashLoan(uint _amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(_amount);
    }

    function receiveTokens(address _tokenAddress, uint256 _amount) external {
        require(msg.sender == address(pool), "Sender must be pool");
        
        // Require funds received
        require(Token(_tokenAddress).balanceOf(address(this)) == _amount, "Failed to get loan");
        
        // Emit event
        emit LoanReceived(_tokenAddress, _amount);
        
        
        // Do stuff with the money...


        // Returns funds to pool
    }

}