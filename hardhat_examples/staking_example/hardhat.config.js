require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.30",
    networks: {
        jovay_mainnet: {
            url: process.env.JOVAY_MAINNET_RPC_URL || "",
            chainId: 5734951,
            accounts:
                process.env.MAINNET_PRIVATE_KEY !== undefined ? [process.env.MAINNET_PRIVATE_KEY] : [],
        },
        jovay_testnet: {
            url: process.env.JOVAY_TESTNET_RPC_URL || "",
            chainId: 2019775,
            accounts:
                process.env.TESTNET_PRIVATE_KEY !== undefined ? [process.env.TESTNET_PRIVATE_KEY] : [],
        }
    },
};
