require("@nomiclabs/hardhat-waffle");

module.exports = {
	defaultNetwork: "hardhat",
	networks: {
		localhost: {
			url: "http://127.0.0.1:8545",
		},
		hardhat: {
			chainId: 1337,
		},
		testnet: {
			url: "https://data-seed-prebsc-1-s1.binance.org:8545",
			chainId: 97,
			gasPrice: 20000000000,
			accounts: [
				"b95c15a53fcf988fe7a7eb57f6294fb9baf835cef19372ba962c6aa52cc58480",
			],
		},
		mainnet: {
			url: "https://bsc-dataseed.binance.org/",
			chainId: 56,
			gasPrice: 20000000000,
			accounts: [
				"b95c15a53fcf988fe7a7eb57f6294fb9baf835cef19372ba962c6aa52cc58480",
			],
		},
	},
	solidity: {
		version: "0.8.13",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
};
