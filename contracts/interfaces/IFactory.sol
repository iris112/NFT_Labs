//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IFactory {
  struct TokenDetails {
    bool isForSale;
    address payable owner;
    uint256 tokenId;
    uint256 saleId;
    uint256 price;
  }
  
  function nftsForSale(address tokenAddress, uint256 saleId) external view returns (TokenDetails memory);
  function mintCFromOA(uint256 tokenId) external;
  function mintOAFromC(uint256 tokenId) external;
}
