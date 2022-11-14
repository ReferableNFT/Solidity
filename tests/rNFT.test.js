// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC_rNFT", function () {
    it("test metadata", async function () {
        const RNFT = await ethers.getContractFactory("ERC_rNFT.sol:ERC_rNFT");
        const rNFT = await RNFT.deploy();
        await rNFT.deployed();
        console.log('erc_rnft deployed at:'+ rNFT.address);
        expect((await rNFT.symbol())).to.equal('SBC');
        expect((await rNFT.name())).to.equal('SaberCoin');
    });
});