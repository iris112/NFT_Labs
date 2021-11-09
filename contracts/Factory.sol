// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./utils/Ownable.sol";
import "./library/SafeMath.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IERC721.sol";
import "./interfaces/IERC721Util.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/ITokenForSale.sol";
import "./library/Counters.sol";

contract Factory is Ownable {
  using SafeMath for uint256;
  using Counters for Counters.Counter;
  
  address public PNFTToken;
  address public OANFTToken;
  address public CNFTToken;

  Counters.Counter internal saleIdCounter;

  //Mapping by marketplace listing by Id to token details.
  // token address => sale id => token details
  mapping(address => mapping(uint256 => IFactory.TokenDetails)) public nftsForSale;
  
  event PriceItemAdded(address tokenAddress, uint256 saleId, uint256 tokenId, uint256 price);
  event PriceItemRemoved(address tokenAddress, uint256 saleId, uint256 tokenId, uint256 price);
  event PriceItemSold(address tokenAddress, uint256 saleId, uint256 tokenId, uint256 price);

  constructor() {}
  
  receive() external payable  {}
  
  function setPNFTToken(address _PNFTToken) external onlyOwner {
      PNFTToken = _PNFTToken;
  }
  
  function setOANFTToken(address _OANFTToken) external onlyOwner {
      OANFTToken = _OANFTToken;
  }
  
  function setCNFTToken(address _CNFTToken) external onlyOwner {
      CNFTToken = _CNFTToken;
  }

  function mintCFromOA(uint256 tokenId) external {
    IERC721Util(OANFTToken).burnFor(msg.sender, tokenId);
    IERC721Util(CNFTToken).mintForWithId(msg.sender, tokenId);
  }

  function mintOAFromC(address minter, uint256 tokenId) external onlyOwner {
    IERC721Util(CNFTToken).burnFor(minter, tokenId);
    IERC721Util(OANFTToken).mintForWithId(minter, tokenId);
  }

  function buyItem(address tokenAddress, uint256 saleId) external payable {
    IFactory.TokenDetails memory detail = nftsForSale[tokenAddress][saleId];

    _checkBuyPossible(detail);
    require(detail.isForSale, "BuyItem: NOT_SELLING");
    nftsForSale[tokenAddress][saleId].isForSale = false;
    
    detail.owner.transfer(msg.value);
    IERC721(tokenAddress).transferFrom(detail.owner, _msgSender(), detail.tokenId);
    ITokenForSale(tokenAddress).removeFromSale(detail.tokenId, saleId);
    emit PriceItemSold(tokenAddress, saleId, detail.tokenId, msg.value);
  }

  function _checkBuyPossible(IFactory.TokenDetails memory detail) private {
    require(_msgSender() != address(0), "BuyItem: INVALID_ADDRESS");
    require(detail.owner != _msgSender(), "BuyItem: IMPOSSIBLE_FOR_OWNER");
    require(msg.value >= detail.price, "BuyItem: LOWER_PRICE");
  }

  function sellItem(address tokenAddress, uint256 tokenId, uint256 price) external {
    require(_msgSender() != address(0), "sellItem: INVALID_ADDRESS");
    require(tokenAddress == PNFTToken || tokenAddress == OANFTToken, "sellItem: INVALID_TOKEN_FOR_SALE");

    uint256 countOfSaleIdsForToken = ITokenForSale(tokenAddress).getCountOfSaleIdsForToken(tokenId);
    require(countOfSaleIdsForToken == 0, "sellItem: ALREADY_IN_SALE");
    
    uint256 newSaleId = _getNewSaleId();
    nftsForSale[tokenAddress][newSaleId] = IFactory.TokenDetails(true, payable(_msgSender()), tokenId, newSaleId, price);
    
    ITokenForSale(tokenAddress).setForSale(tokenId, newSaleId);
    emit PriceItemAdded(tokenAddress, newSaleId, tokenId, price);
  }

  function sellItemCancel(address tokenAddress, uint256 saleId) external {
    IFactory.TokenDetails memory detail = nftsForSale[tokenAddress][saleId];

    require(_msgSender() != address(0), "sellItemCancel: INVALID_ADDRESS");
    require(detail.owner == _msgSender(), "sellItemCancel: ONLY_FOR_OWNER");
    require(detail.isForSale, "sellItemCancel: NOT_SELLING");

    nftsForSale[tokenAddress][saleId].isForSale = false;
    ITokenForSale(tokenAddress).removeFromSale(detail.tokenId, saleId);
    emit PriceItemRemoved(tokenAddress, saleId, detail.tokenId, detail.price);
  }

  function withdrawToken(address _token, uint256 _amount) external onlyOwner {
    IERC20(_token).transfer(msg.sender, _amount);
  }
  
  function withdraw(uint256 _amount) external onlyOwner {
    payable(msg.sender).transfer(_amount);
  }

  function _getNewSaleId() private returns (uint256) {
    saleIdCounter.increment();
    return saleIdCounter.current();
  }
}

