import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Frame", function () {
  async function deployFrameFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Frame = await ethers.getContractFactory("Frame");
    const frame = await Frame.deploy();

    const ExampleNft = await ethers.getContractFactory("ExampleNft");
    const exampleNft = await ExampleNft.deploy("EXAMPLE", "NFT");

    return { frame, exampleNft, owner };
  }

  describe("Deployment", function () {
    // Todo, deploy nft
    it("Should set the right unlockTime", async function () {
      const { frame, exampleNft } = await loadFixture(deployFrameFixture);

      console.log(await frame.getSvgFromNft(0, exampleNft.address))

      // expect(await frame.getSvgFromNft(0, exampleNft.address)).to.equal("");
    });
  });
});
