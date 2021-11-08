// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./utils/ERC721Enumerable.sol";
import "./utils/TokenForSale.sol";
import "./library/Counters.sol";

contract OA_NFT is ERC721Enumerable, TokenForSale {
  using Counters for Counters.Counter;

  Counters.Counter internal tokenIdCounter;

  constructor() ERC721("Original Artwork NFT", "OA-NFT")  {  
    _setBaseURI("https://nftlabs.com/api/OA-NFT/");
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, TokenForSale) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
  
  function mint() external onlyOwner returns(uint256) {
    return _mintItem(_msgSender());
  }

  function mintFor(address minter) external onlyFactory returns(uint256) {
    require(minter != address(0), "OA-NFT: MINTER_IS_ZERO_ADDRESS");
    
    return _mintItem(minter);
  }

  function mintWithCount(uint256 count) external onlyOwner returns(uint256[] memory) {
    require(count <= 100, "OA-NFT: MAX_COUNT_IS_100");

    uint256[] memory retIds = new uint256[](count);

    for (uint256 i = 0; i < count; i++) {
      retIds[i] = _mintItem(_msgSender());
    }
    
    return retIds;
  }

  function mintForWithId(address minter, uint256 tokenId) external onlyFactory {
    require(minter != address(0), "OA-NFT: MINTER_IS_ZERO_ADDRESS");
    require(tokenId > 0, "OA-NFT: INVALID_TOKEN_ID");
    
    _safeMint(minter, tokenId);
  }

  function burn(uint256 tokenId) external {
    address owner = ownerOf(tokenId);
    require(owner == _msgSender(), "OA-NFT: NOT_ITEM_OWNER");
    _burn(tokenId);
  }

  function burnFor(address burner, uint256 tokenId) external onlyFactory {
    address owner = ownerOf(tokenId);
    require(owner == burner, "OA-NFT: NOT_ITEM_OWNER");
    _burn(tokenId);
  }

  function _mintItem(address minter) private returns(uint256) {
    tokenIdCounter.increment();
    uint256 newTokenId = tokenIdCounter.current();

    _safeMint(minter, newTokenId);

    return newTokenId;
  }
}

