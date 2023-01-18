//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

/* --> Interface <-- */
interface IERC721 {
    function safeTransferFrom(
        address sender,
        address nft,
        uint nftId
    ) external;
        
    function transferFrom(
        address,
        address,
        uint 
    ) external;
}
