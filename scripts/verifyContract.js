
require('@nomiclabs/hardhat-etherscan')
const hre = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')
const allowlist_airdrop = require('./allowlist_airdrop.js')
const allowlist_internal = require('./allowlist_internal.js')


//payment splitter
const _team = [
  "0x522ce7ffdA95dAF57B341EEdbb6AEE97cB6cEc1f", // miukki account gets 5% of the total revenue
  "0x28fBd13e980Fca20dB114924926AF802ac1030c5" // sam Account gets 15% of the total revenue
];

const _teamShares = [5, 15]; // 2 PEOPLE IN THE TEAM

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
    address: '0x4437bAb5F116C78760DaA1F829bA7Be40D960524',//latest contract
    constructorArguments: [_team, _teamShares, _notRevealedUri, _revealedUri, root_air, root_int]
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
