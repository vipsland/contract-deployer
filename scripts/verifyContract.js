
require('@nomiclabs/hardhat-etherscan')
const hre = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')
const allowlist_airdrop = require('./allowlist_airdrop.js')
const allowlist_internal = require('./allowlist_internal.js')


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


async function main() {

  await hre.run('verify:verify', {
    address: '0x8f6451715b549c30777331e552f53C9a7E5CB97C',//latest contract
    constructorArguments: [_team, _teamShares, _notRevealedUri, _revealedUri, root_air, root_int]
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
