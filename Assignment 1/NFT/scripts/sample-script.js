// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const [p1, p2, p3] = await hre.ethers.getSigners();
  console.log(
    "p1: %s, \np2: %s, \np3: %s\n ",
    p1.address,
    p2.address,
    p3.address
  );
  const PizzaSlice = await hre.ethers.getContractFactory("PizzaSlice");
  const pizza = await PizzaSlice.deploy();

  await pizza.deployed();
  console.log("Pizza NFT deployed to:", pizza.address, "\n");

  // Mint one NFT to P1
  const txn1 = await pizza.mintTo(p1.address);
  var receipt = await txn1.wait();
  console.log(
    "gas used for minting an NFT to p1: %s",
    parseInt(receipt.cumulativeGasUsed)
  );

  // Mint One NFT to P2
  await pizza.mintTo(p2.address);
  var receipt = await txn1.wait();
  console.log(
    "gas used for minting an NFT to p2: %s",
    parseInt(receipt.cumulativeGasUsed)
  );
  console.log(receipt);

  // Mint One NFT to P3
  await pizza.mintTo(p3.address);
  var receipt = await txn1.wait();
  console.log(
    "gas used for minting an NFT to p3: %s\n",
    parseInt(receipt.cumulativeGasUsed)
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
