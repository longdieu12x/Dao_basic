const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WhiteList", function () {
	let whiteList;
	let flameDevs;
	let dao;
	let marketplace;
	let FDT;
	let owner;
	let addr1;
	let addrs;
	beforeEach(async function () {
		[owner, addr1, ...addrs] = await ethers.getSigners();
		const WhiteList = await ethers.getContractFactory("WhiteList");
		whiteList = await WhiteList.deploy(5);
		const FlameDevs = await ethers.getContractFactory("FlameDevs");
		flameDevs = await FlameDevs.deploy("", whiteList.address, 500);
		const FlameDevsToken = await ethers.getContractFactory("FlameDevsToken");
		FDT = await FlameDevsToken.deploy(flameDevs.address);
		const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
		marketplace = await NFTMarketplace.deploy();
		const FlameDevsDao = await ethers.getContractFactory("FlameDevsDao");
		dao = await FlameDevsDao.deploy(flameDevs.address, marketplace.address);
	});

	describe("After Deployment", function () {
		it("get address of contracts deployed", async function () {
			const whiteListAddress = whiteList.address;
			console.log("white list address is ", whiteListAddress);
			const flameDevsAddress = flameDevs.address;
			console.log("flame devs address is ", flameDevsAddress);
			const FDTAddress = FDT.address;
			console.log("FDT address is ", FDTAddress);
		});
		it("Test mining NFT of flameDevsNFT", async () => {
			const ownerAddress = owner.address;
			await whiteList.addWhitelist(`${ownerAddress}`);
			await flameDevs.startPresale();
			// Start minting
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			expect(
				(await flameDevs.balanceOf(`${ownerAddress}`)).toString()
			).to.be.equal("5");
		});
		it("test mint of FDT", async () => {
			const ownerAddress = owner.address;
			const value = ethers.utils.parseEther("0.05");
			await FDT.mint(500, { value });
			expect((await FDT.balanceOf(ownerAddress)).toString()).to.be.equal(
				ethers.utils.parseEther("500")
			);
		});
		it("claim mint of FDT", async () => {
			const ownerAddress = owner.address;
			await whiteList.addWhitelist(`${ownerAddress}`);
			await flameDevs.startPresale();
			// Start minting
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			// Claim token
			await FDT.claim();
			expect((await FDT.balanceOf(ownerAddress)).toString()).to.be.equal(
				ethers.utils.parseEther("50")
			);
		});
		it("Set duration time in Dao", async function () {
			await dao.setDurationTime(0);
			expect((await dao.getDurationTime()).toString()).to.be.equal("0");
		});
		it("Create proposal", async () => {
			const ownerAddress = owner.address;
			const value = ethers.utils.parseEther("5");
			await whiteList.addWhitelist(`${ownerAddress}`);
			await flameDevs.startPresale();
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await flameDevs.presaleMinted({ value: 1000 * 10 ** 9 }); // mint five times
			await dao.setDurationTime(5);
			await dao.createProposal(15);
			await dao.sendEther({ value });
			expect((await dao.proposals(0)).nftTokenId).to.be.eq(15);
			await dao.voteOnProposal(0, 0);
			expect((await dao.proposals(0)).yayVotes).to.be.eq(5);
			await dao.executeProposal(0);
			expect((await dao.proposals(0)).executed).to.be.eq(true);
		});
	});
});
