require("@nomicfoundation/hardhat-toolbox");
require('hardhat-contract-sizer');
require('solidity-coverage');
require("dotenv").config();

const { SEPOLIA_RPC_URL, GOERLI_RPC_URL, SEPOLIA_PRIVATE_KEY, GOERLI_PRIVATE_KEY, ETHERSCANAPIKEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.17',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {

    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [`0x${SEPOLIA_PRIVATE_KEY}`],
      saveDeployments: true,
    },

    goerli: {
      url: GOERLI_RPC_URL,
      accounts: [`0x${GOERLI_PRIVATE_KEY}`],
      saveDeployments: true,
    },

    hardhat: {
      accounts: {
        // mnemonic: MNEMONIC,
        // path: "m/44'/60'/0'/0/",
        // initialIndex: 0,
        count: 10,
      }
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts'
  },
  mocha: {
    timeout: 60000
  },
  etherscan: {
    apiKey: {
      rinkeby: ETHERSCANAPIKEY,
      goerli: ETHERSCANAPIKEY,
      sepolia: ETHERSCANAPIKEY
    },
    customChains: [
      {
        network: "rinkeby",
        chainId: 4,
        urls: {
          apiURL: "https://api-rinkeby.etherscan.io/api",
          browserURL: "https://rinkeby.etherscan.io"
        }
      },
      {
        network: "goerli",
        chainId: 5,
        urls: {
          apiURL: "https://api-goerli.etherscan.io/api",
          browserURL: "https://goerli.etherscan.io"
        }
      },
      {
        network: "sepolia",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: "https://sepolia.etherscan.io"
        }
      }
    ]

  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
  }
};

//npx hardhat accounts
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log({ address: account.address, balance: account.balance });
  }
});

