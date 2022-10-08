// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 , ERC721URIStorage , Ownable {
    using Counters for Counters.Counter;                // prevents uint overflows

    Counters.Counter private _tokenIdCounter;
    address contractAddress;                            // address of marketplace

    constructor() ERC721("MyToken", "NFT") {}

    function safeMint(address to, string memory uri) public onlyOwner returns(uint256){
        uint256 tokenId = _tokenIdCounter.current();        // gets hold of tokenid
        _tokenIdCounter.increment();                        // increases it for next token
        _safeMint(to, tokenId);                             // mints it with tokenid to owner
        _setTokenURI(tokenId, uri);                         // sets token uri
        setApprovalForAll(contractAddress, true);           // sets approval for marketplace to handle token
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}