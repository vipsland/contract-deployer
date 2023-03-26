/**
 *  This script will calculate the constructor arguments for PRT.sol and deploy it.
 *  After deploying, you can access the contract on etherscan.io with the deployed contract address.
 */

const hre = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')
const whitelist = require('./whitelist.js')

async function main() {

  const signers = await ethers.getSigners()
  const [deployer] = signers

  console.log('Deploying contracts with the account:', deployer.address)

  console.log('Account balance:', (await deployer.getBalance()).toString())


  //payment splitter
  const _team = [
    '0x1090C62B584c1c9a56E3D8AFd70cf9F2ECee17CC', // miukki account gets 5% of the total revenue
    '0x06f10E01E97718730179F53Bc6f8ff6625ACB2f1' // sam Account gets 15% of the total revenue
  ];
  const _teamShares = [5, 15]; // 2 PEOPLE IN THE TEAM

  const _notRevealedUri = "https://ipfs.vipsland.com/nft/collections/genesis/json/hidden.json";
  const _revealedUri = "https://ipfs.vipsland.com/nft/collections/genesis/json/";

  const leafNodes = whitelist.map((addr) => keccak256(addr))
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true })
  const root = merkleTree.getRoot()


  // Deploy the contract
  const PRTFactory = await hre.ethers.getContractFactory('Vipsland')
  const vipslandContract = await PRTFactory.deploy(
    // BASE_URI,
    // root,
    // proxyRegistryAddressGoerli
    _team,
    _teamShares,
    _notRevealedUri,
    _revealedUri,
    root
  )

  await vipslandContract.deployed()

  console.log('VipslandContract deployed to:', vipslandContract.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
