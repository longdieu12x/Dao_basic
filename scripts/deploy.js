const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");

async function main() {
	const whitelistContract = WHITELIST_CONTRACT_ADDRESS;
	const metadataURL = METADATA_URL;
	const flameDevsContract = await ethers.getContractFactory("FlameDevs");

	// deploy the contract
	const deployedFlameDevsContract = await flameDevsContract.deploy(
		metadataURL,
		whitelistContract
	);
	console.log(
		"Flame Devs Contract Address:",
		deployedFlameDevsContract.address
	);
}

// Call the main function and catch if there is any error
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
