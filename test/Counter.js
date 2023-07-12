const {expect} = require('chai');
const {ethers} = require('hardhat'); // library that turns your website into a blockchain website and allows you to interact with nodes on the blockchain


//you must add the async keyword to the function call to indicate that it is a async function. 
//Then, you will be able to use the await keyword infront of functions to await for values being grabbed from the blockchain
describe('Counter', () => {

    let counter;

    //instead of doing this every time, use a beforeEach to run this block of code before every test
    beforeEach(async () => {
        const Counter = await ethers.getContractFactory('Counter'); // framework that is able to fetch contract that we specifiy. Counter is the ether contract
        counter = await Counter.deploy('My Counter', 1); // .deploy creates contract and parameters are the inputs of the constructor that are needed to deploy. This is the deployed contract
    })

    describe('Deployment', () => {
        it('checks initial count', async () => {
            expect(await counter.count()).to.equal(1);
        })
    
        it('checks the initial name', async () => {
            const name = await counter.name(); 
            expect(name).to.equal('My Counter');
        })
    })

    describe('Counting', () => {
        let transaction;

        it('reads the count from the "count" public variable', async () => {
            expect(await counter.count()).to.equal(1);
        })

        it('reads the count from the "getCount" function', async () => {
            expect(await counter.getCount()).to.equal(1);
        })

        it('increments the count', async () => {
            transaction = await counter.increment();
            await transaction.wait(); //waits for the function to be fully called before moving on

            expect(await counter.count()).to.equal(2);

            transaction = await counter.increment();
            await transaction.wait(); 

            expect(await counter.count()).to.equal(3);
        })

        it('decrements the count', async () => {
            transaction = await counter.decrement();
            await transaction.wait();

            expect(await counter.count()).to.equal(0);

            //Cannot decrement count below 0
            await expect(counter.decrement()).to.be.reverted;
        })

        it('reads the name from the "name" public variable', async () => {
            expect(await counter.name()).to.equal('My Counter');
        })

        it('reads the name from the "getName" function', async () => {
            expect(await counter.getName()).to.equal('My Counter');
        })

        it('updates the name', async () => {
            transaction = await counter.setName('Michael Koch');
            await transaction.wait();
            expect (await counter.name()).to.equal('Michael Koch');
        })


    })

})

