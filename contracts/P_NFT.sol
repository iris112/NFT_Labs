// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./utils/ERC721Enumerable.sol";
import "./utils/TokenForSale.sol";
import "./library/Counters.sol";

contract P_NFT is ERC721Enumerable, TokenForSale {
  using Counters for Counters.Counter;

  Counters.Counter internal tokenIdCounter;

  constructor() ERC721("Poster NFT", "P-NFT")  {  
    _setBaseURI("https://nftlabs.com/api/P-NFT/");
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, TokenForSale) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
  
  function mint() external onlyOwner returns(uint256) {
    return _mintItem(_msgSender());
  }

  function mintFor(address minter) external onlyFactory returns(uint256) {
    require(minter != address(0), "P-NFT: MINTER_IS_ZERO_ADDRESS");
    
    return _mintItem(minter);
  }

  function mintWithCount(uint256 count) external onlyOwner returns(uint256[] memory) {
    require(count <= 2500, "P-NFT: MAX_COUNT_IS_2500");

    uint256[] memory retIds = new uint256[](count);

    for (uint256 i = 0; i < count; i++) {
      retIds[i] = _mintItem(_msgSender());
    }
    
    return retIds;
  }

  function burn(uint256 tokenId) external {
    address owner = ownerOf(tokenId);
    require(owner == _msgSender(), "P-NFT: NOT_ITEM_OWNER");
    _burn(tokenId);
  }

  function isHavePNFT(address account) external view returns (bool) {
    return balanceOf(account) > 0;
  }

  function _mintItem(address minter) private returns(uint256) {
    tokenIdCounter.increment();
    uint256 newTokenId = tokenIdCounter.current();

    _safeMint(minter, newTokenId);

    return newTokenId;
  }
}

