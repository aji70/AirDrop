import { ethers } from "hardhat";

async function main() {
  const AirdropGames = await ethers.deployContract("AirdropGames", [9761]);

  await AirdropGames.waitForDeployment();

  console.log(
    ` AjiVRFv2Consumer contract was deployed to ${AirdropGames.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
