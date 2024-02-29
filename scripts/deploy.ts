import { ethers } from "hardhat";

async function main() {
  const AjiVRFv2Consumer = await ethers.deployContract("AjiVRFv2Consumer", [
    9761,
  ]);

  await AjiVRFv2Consumer.waitForDeployment();

  console.log(
    ` AjiVRFv2Consumer contract was deployed to ${AjiVRFv2Consumer.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
