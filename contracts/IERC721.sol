// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin-contracts/token/ERC721/ERC721.sol";

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function transferFrom(
        address,
        address,
        uint
    ) external;
}
