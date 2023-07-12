const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether');
}

const ether = tokens;

describe('RealEstate', () => {

    let realEstate, escrow;
    let accounts, deployer, seller, inspector, lender;
    let nftID = 1;
    let purchasePrice = ether(100);
    let escrowAmount = ether(20);

    beforeEach(async () => {

        // Setup Accounts
        accounts = await ethers.getSigners(); // getSigners is used to get a list of accounts in the node you're connecting to
        deployer = accounts[0];
        seller = deployer;
        buyer = accounts[1];
        inspector = accounts[2];
        lender = accounts[3];

        // Load contracts
        const RealEstate = await ethers.getContractFactory('RealEstate');
        const Escrow = await ethers.getContractFactory('Escrow');

        // Deploy Contracts
        realEstate = await RealEstate.deploy()
        escrow = await Escrow.deploy(
            realEstate.address, //reads address from real estate NFT
            nftID,
            purchasePrice,
            escrowAmount,
            seller.address,
            buyer.address,
            inspector.address,
            lender.address
        );

        // Seller Approves NFT
        transaction = await realEstate.connect(seller).approve(escrow.address, nftID);
        await transaction.wait();
    })

    describe('Deployment', async () => {
        it('sends an NFT to the seller / deployer', async () => {
            expect(await realEstate.ownerOf(nftID)).to.equal(seller.address);
        })
    })

    describe('Selling real estate', async () => {
        let balance, etherBalance, transaction;

        it('executes a successful transaction', async () => {
            // Expects seller to be NFT owner before the sale
            expect(await realEstate.ownerOf(nftID)).to.equal(seller.address);

            // Check escrow balance before deposit
            balance = await escrow.getBalance();
            expect(ethers.utils.formatEther(balance)).to.equal("0.0");

            // Buyer deposits earnest
            transaction = await escrow.connect(buyer).depositEarnest({ value: escrowAmount });

            // Check escrow balance after deposit
            balance = await escrow.getBalance();
            expect(ethers.utils.formatEther(balance)).to.equal("20.0");

            // Inspector updates status
            transaction = await escrow.connect(inspector).updateInspectionStatus(true);
            await transaction.wait();
            console.log("Inspector updates status");
            //expect(escrow.inspectionPassed).to.equal(true);

            // Buyer Approves sale
            transaction = await escrow.connect(buyer).approveSale();
            await transaction.wait();
            console.log("Buyer approves sale");

            // Seller Approves sale
            transaction = await escrow.connect(seller).approveSale();
            await transaction.wait();
            console.log("Seller approves sale");

            // Lender funds sale
            transaction = await lender.sendTransaction({ to: escrow.address, value: ether(80) }); // .sendTransaction is a function within ether that is used to send money from one account to another

            // Lender Approves sale
            transaction = await escrow.connect(lender).approveSale();
            await transaction.wait();
            console.log("Lender approves sale");

            // Finalize sale
            transaction = await escrow.connect(buyer).finalizeSale(); //connect allows us to act as the buyer whenever we connect to the smart contract in javascript
            await transaction.wait();
            console.log("Buyer finalizes sale");

            // Expects buyer to be NFT owner before the sale
            expect(await realEstate.ownerOf(nftID)).to.equal(buyer.address);

             // Expect Seller to receive Funds
             balance = await ethers.provider.getBalance(seller.address);
             console.log("Seller balance:", ethers.utils.formatEther(balance));
             expect(balance).to.be.above(ether(10099));
        })
    })
})