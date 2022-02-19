// Right click on the script name and hit "Run" to execute
(async () => {
  try {
    console.log("Running deployWithEthers script...");

    const contractName = "OptimizedBallot"; // Change this for other contract
    const constructorArgs = [
      [
        ethers.utils.hexZeroPad(web3.utils.asciiToHex("proposal1"), 32),
        ethers.utils.hexZeroPad(web3.utils.asciiToHex("proposal2"), 32),
      ],
    ]; // Put constructor args (if any) here for your contract

    // Note that the script needs the ABsI which is generated from the compilation artifact.
    // Make sure contract is compiled and artifacts are generated
    const artifactsPath = `browser/contracts/artifacts/${contractName}.json`; // Change this for different path
    const metadata = JSON.parse(
      await remix.call("fileManager", "getFile", artifactsPath)
    );
    const provider = new ethers.providers.Web3Provider(web3Provider);
    const currentSigner = await provider.getSigner();
    const currentSignerAdr = await currentSigner.getAddress();

    // Create and deploy the Ballot contract
    let factory = new ethers.ContractFactory(
      metadata.abi,
      metadata.data.bytecode.object,
      currentSigner
    );
    let contract = await factory.deploy(...constructorArgs);
    console.log("Contract Address: ", contract.address);
    await contract.deployed();

    // Store 10 signers to an array
    const voters = Array.from({ length: 10 }, (_, i) => provider.getSigner(i));

    // Grant all participants the right to vote and update the cumulated gas used
    var gasForOriginalBallot = 0;

    let tx = await contract.giveRighToVoteToAllVoters();
    let receipt = await tx.wait();
    gasForOriginalBallot += parseInt(receipt.cumulativeGasUsed);

    // Outputs 26,562
    console.log(
      "total wei spent on gas for transaction: \t",
      ethers.utils.formatUnits(gasForOriginalBallot, "wei")
    );
  } catch (e) {
    console.log(e.message);
  }
})();
