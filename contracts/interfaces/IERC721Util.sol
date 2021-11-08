// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

interface IERC721Util {
    function burn(uint256 tokenId) external;
    function burnFor(address burner, uint256 tokenId) external;
    function mintForWithId(address minter, uint256 tokenId) external;
}
