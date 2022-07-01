require('dotenv').config();
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";

export const defaultNetwork = "matic";
export const networks = {
  hardhat: {},
  matic: {
    url: "https://rpc-mumbai.maticvigil.com",
    accounts: [process.env.PRIVATE_KEY]
  }
};
export const etherscan = {
  apiKey: process.env.POLYGONSCAN_API_KEY
};
export const solidity = {
  version: "0.8.0",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  }
};