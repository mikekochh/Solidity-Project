// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Bank is ReentrancyGuard {

    using Address for address payable;

    mapping(address => uint256) public balanceOf;

    // deposit ether funds
    function deposit() external payable {
        // update bank amount sent in from msg.value for msg.sender
        balanceOf[msg.sender] += msg.value;
    }
    // withdraw ether funds

    function withdrawl() external nonReentrant {
        uint256 depositedAmount = balanceOf[msg.sender];
        payable(msg.sender).sendValue(depositedAmount);
        // once the line above this is hit, the receive function in attacker is called next.
        // The code cannot get to the next line because receive function continues to be called recursively
        // and it is just arbitraly sending an amount from the bank to the attacker
        // the nonReentrant modifier prevents Reentrancy from occuring and breaks the test
        balanceOf[msg.sender] = 0;
    }
}