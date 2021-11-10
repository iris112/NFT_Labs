// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./utils/Ownable.sol";
import "./library/SafeMath.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IP_NFT.sol";
import "./library/Counters.sol";

/**
 * @title Lottery
 * @author NFT Labs
 * @dev Lottery should work as follows:
 * 1. Lottery period starts
 * 2. Users interact with smart contract to enter their wallets into the draw
 * 3. Entry period ends.
 * 4. Winning wallets determined randomly.
 * 5. Claim/mint period starts.
 * 6. Claim/mint period ends.
 * 7. Unclaimed NFTs sent to team wallet.
 */
contract Lottery is Ownable {
  using SafeMath for uint256;
  using Counters for Counters.Counter;
  
  struct Ticket {
      bool exist;
      uint256 block;
      uint256 ticketId;
      bool claimed;
  }
  address public PNFTToken;
  bool isActive;
  bool isClaimActive;
  uint256 winningPercent = 50;
  Counters.Counter internal ticketIdCounter;
  mapping(address => Ticket) private tickets;

  
  event Won(address player, uint256 ticketId, uint256 tokenId);
  event NewTicket(address player, uint256 ticketId);

  constructor() {}
  
  receive() external payable  {}
  
  function setPNFTToken(address _PNFTToken) external onlyOwner {
    PNFTToken = _PNFTToken;
  }
  
  function setWinningPercent(uint256 _winningPercent) external onlyOwner {
    winningPercent = _winningPercent;
  }
  
  function activateEntry() external onlyOwner {
    isActive = true;
  }
  
  function stopEntry() external onlyOwner {
    isActive = false;
  }
  
  function activateClaim() external onlyOwner {
    isClaimActive = true;
  }
  
  function stopClaim() external onlyOwner {
    isClaimActive = false;
  }
  
  function getResult(address account) external view returns (bool) {
    return getBetResult(account);
  }
  
  function play() external payable {
    _checkPlayPossible();
    tickets[_msgSender()] = Ticket(true, block.number, _getNewTicketId(), false);
    emit NewTicket(_msgSender(), tickets[_msgSender()].ticketId);
  }
  
  function claim() external {
    if (getBetResult(_msgSender())) {
      tickets[_msgSender()].claimed = true;
      uint256 tokenId = IP_NFT(PNFTToken).tokenOfOwnerByIndex(address(this), 0);
      emit Won(_msgSender(), tickets[_msgSender()].ticketId, tokenId);
      IP_NFT(PNFTToken).transferFrom(address(this), _msgSender(), tokenId);
    }
  }

  function _checkPlayPossible() private view {
    require(isActive, "PlayItem: NOT_ACTIVE");
    require(_msgSender() != address(0), "PlayItem: INVALID_ADDRESS");
    require(!tickets[_msgSender()].exist, "PlayItem: ONLY_ONCE");
    require(IP_NFT(PNFTToken).isHavePNFT(address(this)), "PlayItem: NO_P_NFTS");
  }

  function getBet(address account, uint256 _block) private view returns (uint256) {
    uint256 tempBlock = _block;
    bytes32 firstblock = blockhash(tempBlock);
    bytes32 secondblock = blockhash(tempBlock.add(1));
    bytes memory bytesArray = new bytes(32);
    bytes memory player = abi.encodePacked(account);

    for (uint256 i; i < 15; i++) {
      bytesArray[i] = firstblock[7 + i];
    }

    bytesArray[15] = player[7];
    
    for (uint256 i = 16; i < 32; i++) {
      bytesArray[i] = secondblock[i];
    }

    return uint(keccak256( bytesArray )) >> 16;
  }
  
  function getBetResult(address account) private view returns (bool) {
    Ticket memory accountTicket = tickets[account];
    uint256 blockNumber = block.number;
    require(accountTicket.exist, "BetResult: NOT_EXIST");    
    require(isClaimActive, "PlayItem: NOT_ACTIVE");
    require(IP_NFT(PNFTToken).isHavePNFT(address(this)), "PlayItem: NO_P_NFTS");
    require(!accountTicket.claimed, "PlayItem: P_NFT_SENT");
    
    uint256 dice = getBet(account, accountTicket.block);
    if (dice % 100 < winningPercent) {
      return false;
    } else {
      return true;
    }
  }

  function withdrawToken(address _token, uint256 _amount) external onlyOwner {
    IERC20(_token).transfer(msg.sender, _amount);
  }
  
  function withdraw(uint256 _amount) external onlyOwner {
    payable(msg.sender).transfer(_amount);
  }
  
  function withdrawPNFT() external onlyOwner {
    require(IP_NFT(PNFTToken).isHavePNFT(address(this)), "PlayItem: NO_P_NFTS");

    uint256 count = IP_NFT(PNFTToken).balanceOf(address(this));
    uint256 tokenId;
    for (uint256 i = 0; i < count; i++) {
      tokenId = IP_NFT(PNFTToken).tokenOfOwnerByIndex(address(this), 0);
      IP_NFT(PNFTToken).transferFrom(address(this), _msgSender(), tokenId);
    }
  }
  
  function burnPNFT() external onlyOwner {
    require(IP_NFT(PNFTToken).isHavePNFT(address(this)), "PlayItem: NO_P_NFTS");

    uint256 count = IP_NFT(PNFTToken).balanceOf(address(this));
    uint256 tokenId;
    for (uint256 i = 0; i < count; i++) {
      tokenId = IP_NFT(PNFTToken).tokenOfOwnerByIndex(address(this), 0);
      IP_NFT(PNFTToken).burn(tokenId);
    }
  }

  function _getNewTicketId() private returns (uint256) {
    ticketIdCounter.increment();
    return ticketIdCounter.current();
  }
}

