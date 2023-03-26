
require('@nomiclabs/hardhat-etherscan')
const hre = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')
const whitelist = require('./whitelist.js')


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


async function main() {

  await hre.run('verify:verify', {
    address: '0xDeA6e1bCBEBC753524F2f9752f45527a3Ed05257',//latest
    constructorArguments: [_team, _teamShares, _notRevealedUri, _revealedUri, root]
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
