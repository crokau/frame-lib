//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import '@openzeppelin/contracts/utils/Base64.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Frame {

    function getTokenURI(uint256 tokenId, address nftAddress) public view returns (string memory) {
        IERC721Metadata nftContract = IERC721Metadata(nftAddress);
        
        return nftContract.tokenURI(tokenId);
    }

    function getNft(uint256 tokenId, address nftContract) public view returns (string memory) {
        return getTokenURI(tokenId, nftContract);
    }

    function getSubstringFrom(string memory input, uint start) public pure returns (string memory) {
        require(start < bytes(input).length, "Start position is outside the string");

        bytes memory inputBytes = bytes(input);
        bytes memory outputBytes = new bytes(inputBytes.length - start);

        for (uint i = start; i < inputBytes.length; i++) {
            outputBytes[i - start] = inputBytes[i];
        }

        return string(outputBytes);
    }

    function decodeImage(bytes memory input) public pure returns (string memory) {
        bytes memory inputBytes = input;
        bytes memory prefixBytes = bytes("svg+xml;base64,");
        uint256 inputLength = inputBytes.length;
        uint256 prefixLength = prefixBytes.length;
        uint256 startIndex;
        uint256 commaIndex;
        for (uint256 i = 0; i <= inputLength - prefixLength; i++) {
            bool foundPrefix = true;
            for (uint256 j = 0; j < prefixLength; j++) {
                if (inputBytes[i + j] != prefixBytes[j]) {
                    foundPrefix = false;
                    break;
                }
            }
            if (foundPrefix) {
                startIndex = i + prefixLength;
                break;
            }
        }
        if (startIndex == 0) {
            return "";
        }
        for (uint256 i = startIndex; i < inputLength; i++) {
            if (inputBytes[i] == '"') {
                commaIndex = i;
                break;
            }
        }
        if (commaIndex == 0) {
            commaIndex = inputLength;
        }
        bytes memory outputBytes = new bytes(commaIndex - startIndex);
        for (uint256 i = startIndex; i < commaIndex; i++) {
            outputBytes[i - startIndex] = inputBytes[i];
        }
        return string(outputBytes);
    }

    function getSvgFromNft(uint256 tokenId, address nftContract) public view returns (string memory) {
        string memory rawNft = getNft(tokenId, nftContract);
        bytes memory metadata = decode(getSubstringFrom(rawNft, 29));
        // string memory nft = decodeImage(metadata);
        bytes memory newNft =  abi.encodePacked(
            '<svg id="NEW_NFT_WITH_OTHER_ONE_INSIDE">',
                decode(decodeImage(metadata)),
            '</svg>'
        );

        bytes memory newMetadata = abi.encodePacked(
            '{',
                '"name": "Frame - composed nft', 
                '",',
                '"description": "this is a nft made up of multiple onchain nfts",'
                '"image": ',
                    '"data:image/svg+xml;base64,',
                    Base64.encode(newNft),
                '"',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(newMetadata)
            )
        );

    }

    function substring(string memory str, uint startIndex, uint endIndex) public view returns ( string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";


    function decode(string memory _data) internal pure returns (bytes memory) {
        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        // load the table into memory
        bytes memory table = TABLE_DECODE;

        // every 4 characters represent 3 bytes
        uint256 decodedLen = (data.length / 4) * 3;

        // add some extra buffer at the end required for the writing
        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            // padding with '='
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            // set the actual output length
            mstore(result, decodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 4 characters at a time
            for {} lt(dataPtr, endPtr) {}
            {
               // read 4 characters
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               // write 3 bytes
               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }

}
