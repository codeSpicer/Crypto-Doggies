// require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: process.env.MATIC_TEST,
      accounts: [process.env.PRIVATE_KEY],
    },
    mainnet: {
      url: process.env.MATIC_MAIN,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  solidity: "0.8.17",
};
