
require('@nomiclabs/hardhat-etherscan')
const hre = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')
const allowlist_airdrop = require('./allowlist_airdrop.js')
const allowlist_internal = require('./allowlist_internal.js')


//payment splitter
const _team = [
  '0x1090C62B584c1c9a56E3D8AFd70cf9F2ECee17CC', // miukki account gets 5% of the total revenue
  '0x06f10E01E97718730179F53Bc6f8ff6625ACB2f1' // sam Account gets 15% of the total revenue
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
    address: '0x1237080fC952E6eF04f1C233B5B3eDEa83DE648C',//latest contract
    constructorArguments: [_team, _teamShares, _notRevealedUri, _revealedUri, root_air, root_int]
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
