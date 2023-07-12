// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// skeleton of the smart contract that shows what the function is without importing the entire function itself
// with an interface, we cna import the functions that we care about, without importing all of them
interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _id) external; // allows someone to move tokens from someones wallet into another
}

contract Escrow {

    address public nftAddress;
    uint256 public nftID;
    uint256 public purchasePrice;
    uint256 public escrowAmount; // the amount the buyer must put down to put it in escrow
    address payable public seller; // address is an address of a user and payable is to indicate that this is an address that can receive currency
    address payable public buyer;
    address public inspector;
    address public lender;

    modifier onlyBuyer() {
        require(msg.sender == buyer, "only buyer can call this function"); //msg.sender is the person who is calling the function
        _; // underscore indicates that you cna run the function once this underscore is hit
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "only inspector can call this function"); //msg.sender is the person who is calling the function
        _; // underscore indicates that you cna run the function once this underscore is hit
    }

    bool public inspectionPassed = false;
    mapping(address => bool) public approval;

    // in order for a smart contract to receive funds, it needs a receive function
    // you can put logic inside of the function if you want something to happen every time money is sent to this smart contract
    receive() external payable {}
    
    constructor(
        address _nftAddress, 
        uint256 _nftID, 
        uint256 _purchasePrice,
        uint256 _escrowAmount,
        address payable _seller, 
        address payable _buyer,
        address _inspector,
        address _lender
    ) {
        nftAddress = _nftAddress;
        nftID = _nftID;
        purchasePrice = _purchasePrice;
        escrowAmount = _escrowAmount;
        seller = _seller;
        buyer = _buyer;
        inspector = _inspector;
        lender = _lender;
    }

    
    function finalizeSale() public {
        // Transfer ownership of property
        require(inspectionPassed, "must pass inspection");
        require(approval[buyer], "must have approval from buyer");
        require(approval[seller], "must have approval from sender");
        require(approval[lender], "must have approval from lender");
        require(address(this).balance >= purchasePrice, "must have enough ether for sale");

        // .call is used to send something to a user. What we are doing here is we are sending the entire
        // balance of this smart contract to the seller with no message
        (bool success, ) = payable(seller).call{value: address(this).balance}("");
        require(success);

        IERC721(nftAddress).transferFrom(seller, buyer, nftID);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance; // this is referring to this smart contract
    }

    function depositEarnest() public payable onlyBuyer {
        // Buyer is putting down payment on house/NFT
        // Smart contract will be saving the currency that the buyer is putting down
        // The contract is going to own the money
        require(msg.value >= escrowAmount, "Escrow amount must be 20 ether or more"); // msg.value is the amount of cryptocurrency sent in when this payable function is called
    }

    function updateInspectionStatus(bool _passed) public onlyInspector {
        inspectionPassed = _passed;
    }

    function approveSale() public {
        approval[msg.sender] = true; // whoever calls the approval function is approving of the sale
    }

}
