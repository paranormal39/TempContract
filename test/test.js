const { expect } = require("chai");
const { ethers, deployments, getNamedAccounts } = require("hardhat");

describe("Token Contract", function () {
  let TokenContract;
  let tokenInstance;
  let owner;
  let addr1;
  let addr2;

  
    // Deploy the contract and set up accounts
    before(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
    
        // Deploy the contract
        const Token = await ethers.getContractFactory("Token"); // Replace with your contract name
        tokenInstance = await Token.deploy(owner.address, addr2.address); // Pass owner and donation addresses
    
        // Wait for the contract to be deployed
        await tokenInstance.deployTransaction.wait();
    
        // Check if the contract is deployed correctly
        expect(tokenInstance.address).to.not.be.undefined;
      });
    
      it("Should deploy the contract with the correct owner and initial balance", async function () {
        // Check contract owner
        expect(await tokenInstance.owner()).to.equal(owner.address);
    
        // Check initial balance
        const ownerBalance = await tokenInstance.balanceOf(owner.address);
        const totalSupply = await tokenInstance.totalSupply();
        expect(ownerBalance).to.equal(totalSupply);
      });

  it("Should place a bet with a message", async function () {
    const betAmount = 100;
    const playerScore = 42;
    const message = `${addr1.address} is betting ${betAmount} tokens to pay out to ${owner.address}`;

    await tokenInstance.placeBet(betAmount, playerScore, message);
    const betResult = await tokenInstance.getBettingResult();

    expect(betResult.message).to.equal(message);
    expect(betResult.player).to.equal(addr1.address);
    expect(betResult.betAmount).to.equal(betAmount);
  });

  it("Should transfer tokens between accounts", async function () {
    const initialBalance = await tokenInstance.balanceOf(owner.address);
    const transferAmount = 100;

    // Transfer tokens from owner to addr1
    await tokenInstance.transfer(addr1.address, transferAmount);
    const balanceAfterTransfer1 = await tokenInstance.balanceOf(addr1.address);
    const ownerBalanceAfterTransfer1 = await tokenInstance.balanceOf(owner.address);

    // Check balances
    expect(initialBalance).to.equal(ownerBalanceAfterTransfer1.add(balanceAfterTransfer1));
  });
});
