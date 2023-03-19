# On-chain NFT coposing library

Building block for NFT devs.

Takes onchain nft outputs that look like:
```"data:application/json;base64,eyJuYW1lIjogI ... " ```
and gives you
```<svg id="someNFT"> ... </svg ```
Without leaving your contract!

Then you can do stuff like:
```<svg id="composeNftIntoNewNft"> [<svg id="someNFT"> ... </svg] </svg ```

This is a creative technical project to give a glimpse into the possibilities of true unstoppable interoperable NFTs.

This project demonstrates usage of the onchain frame library to decode a onchain NFT and compose it into a new NFT, all within a smart contract with ZERO offchain code.

Try running some of the following tasks:

```shell
npm i
npx hardhat test
```
