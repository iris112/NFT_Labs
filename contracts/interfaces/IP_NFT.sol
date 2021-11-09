// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721Enumerable.sol";


interface IP_NFT is IERC721, IERC721Enumerable {
  function isHavePNFT(address account) external view returns (bool);
  function burn(uint256 tokenId) external;
}
