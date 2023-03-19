import { ethers } from "hardhat";

async function main() {
  const Frame = await ethers.getContractFactory("Frame");
  const frame = await Frame.deploy();
  await frame.deployed();

  const ExampleNft = await ethers.getContractFactory("Frame");
  const exampleNft = await ExampleNft.deploy();
  await exampleNft.deployed();

  console.log(
    `Frame deployed ${frame.address}
    ExampleNft deployed ${frame.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
