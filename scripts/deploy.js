/**
 *  This script will calculate the constructor arguments for PRT.sol and deploy it.
 *  After deploying, you can access the contract on etherscan.io with the deployed contract address.
 */

const hre = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')
const allowlist_airdrop = require('./allowlist_airdrop.js')
const allowlist_internal = require('./allowlist_internal.js')

async function main() {

  const signers = await ethers.getSigners()
  const [deployer] = signers

  console.log('Deploying contracts with the account:', deployer.address)

  console.log('Account balance:', (await deployer.getBalance()).toString())


  //payment splitter
  const _team = [
    "0xB3EAF78A0a80DE4fec11f9299Cd061BA3F903f53", // miukki 
    "0x2f32198d8C00c2f42c16571729AE7dBFBE57Fc4A",  // sam  
    "0x03b850C66bbB0F7B1b1cBCDbFf2bFc9D7dE6eD4F" //owner
  ];
  const _teamShares = [5, 15, 80]; // 2 PEOPLE IN THE TEAM

  const _notRevealedUri = "https://ipfs.vipsland.com/nft/collections/genesis/json/hidden.json";
  const _revealedUri = "https://ipfs.vipsland.com/nft/collections/genesis/json/";

  const leafNodes_air = allowlist_airdrop.map((addr) => keccak256(addr))
  const merkleTree_air = new MerkleTree(leafNodes_air, keccak256, { sortPairs: true })
  const root_air = merkleTree_air.getRoot()

  const leafNodes_int = allowlist_internal.map((addr) => keccak256(addr))
  const merkleTree_int = new MerkleTree(leafNodes_int, keccak256, { sortPairs: true })
  const root_int = merkleTree_int.getRoot()


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
    root_air,
    root_int
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
