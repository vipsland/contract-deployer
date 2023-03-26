/**
 *  This array contains the addresses of the whitelisted users.
 *  Make sure to add your white-listed users to this array. 
 *
 *  if you add a new user address to the whitelist or remove an existing user address from the whitelist,
 *  you must change the merkleroot in the contract. For this reason, I created a new script to update the merkleroot
 *  in the contract. You can find it in `scripts/setMerkleRoot.js`.
 */

module.exports = [
  '0xe72A5822248a49E1C7E4b9B0e3c2e5FCaEEeBcc0',
  '0x1090C62B584c1c9a56E3D8AFd70cf9F2ECee17CC'
]
