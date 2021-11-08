// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./utils/ERC721Enumerable.sol";
import "./utils/TokenForSale.sol";
import "./library/Counters.sol";

contract C_NFT is ERC721Enumerable, TokenForSale {

  constructor() ERC721("Claimed NFT", "C-NFT")  {  
    _setBaseURI("https://nftlabs.com/api/C-NFT/");
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, TokenForSale) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function mintForWithId(address minter, uint256 tokenId) external onlyFactory {
    require(minter != address(0), "C-NFT: MINTER_IS_ZERO_ADDRESS");
    require(tokenId > 0, "C-NFT: INVALID_TOKEN_ID");
    
    _safeMint(minter, tokenId);
  }

  function burn(uint256 tokenId) external {
    address owner = ownerOf(tokenId);
    require(owner == _msgSender(), "C-NFT: NOT_ITEM_OWNER");
    _burn(tokenId);
  }

  function burnFor(address burner, uint256 tokenId) external onlyFactory {
    address owner = ownerOf(tokenId);
    require(owner == burner, "C-NFT: NOT_ITEM_OWNER");
    _burn(tokenId);
  }
}

