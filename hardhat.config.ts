import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-ethers";
require('dotenv').config()

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999,
      },
    },
  },
  networks: {
    hardhat: {
    },
    mainnet: {
      url: `https://rpc.frax.com`,
      accounts: [process.env.PRIVATE_KEY as string]
    }
  },
  etherscan: {
  },
  sourcify: {
    enabled: false
  }
};

export default config;
