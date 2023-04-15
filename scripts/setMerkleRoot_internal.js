/**
 *   This script will calculate the merkle root from the whitelist array and set it to the contract
 *   using the `setMerkleRoot` function defined in BoredApe.sol contract. For this script to work your contract
 *   already should be deployed and you should have the deployed contract address. If you make a change in whitelist.js
 *   make sure you update the merkleroot in the contract using the script `scripts/setMerkleRoot.js`
 */

const hre = require('hardhat')
const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')
const allowlist_internal = require('./allowlist_internal.js')

async function main() {
  const nftFactory = await hre.ethers.getContractFactory('Vipsland')
  const nftContract = await nftFactory.attach(
    '0x8f6451715b549c30777331e552f53C9a7E5CB97C' // Deployed contract address, goerli latest 0x7a3fbd8266b760e1e9cB2A5795942509C8fF42ae
  )

  // Re-calculate merkle root from the whitelist array.
  const leafNodes = allowlist_internal.map((addr) => keccak256(addr))
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true })
  const root = merkleTree.getRoot()

  // Set the re-calculated merkle root to the contract.
  const res = await nftContract.setMerkleRoot(root, 2)
  console.log({ res })

  console.log('Whitelist root set to:', root)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
