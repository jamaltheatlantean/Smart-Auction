# Smart-Auction Contract

This is a full smart contract for handling multiple auctions of ERC721 tokens. The contract has a self destruct function that can only be called when all items have been sold.

## Features

-   The contract can hold multiple ERC721 tokens and award them to the highestBidder.
-   The contracts ownership can be transferred to a new address incase of need.
-   When a bid has been outbidded the bidder can withdraw his ETH and bid higher.
-   The contract has a self-destruct function that sends all unclaimed funds to the owners address. Tp prevent loss of unclaimed funds, this function can only be called when there arent any funds left in the contract. `require(address(this).balance == 0)`.

## Events

The contract includes the following events:

-   ` event AuctionOpen(address indexed owner)`: Emitted when the application is declared active by the owner.
-   `event ItemCreated(address indexed seller, uint timestamp, uint _auctionId)`: Emitted when an item has been created for auctioning. It emits the seller, time created and an identification number stored in its array.
-   `event AuctionStarted(uint indexed _auctionId)`: Emitted when created item has been declared up for sale by the seller. Starting its 7 days on the auction countdown. It emits the identification number of this item.
-   `event ItemBidIncreased(address indexed sender, uint bid, uint indexed _auctionId)`: Emitted when the bid on an item has been increased, cancelling out a previous bid. It emits the addrress of the bidder `msg.sender`, the amount bidded, and the identification number of the item.
-   `event BalanceClaimed(address indexed sender, uint bal)`: Emitted when a bidder claims his outbidded balance from the contract. It emits the bidders address and the amount `bal`.
-   `event ItemSold(address winner, uint amount)event ItemSold(address winner, uint amount)`: Emitted when the 7 days auction is over and the item has been awarded to the highest bidder `highestBidder`. It emits the addrress of the winning bidder and the amount the item sold for.
-   `event AuctionClosed(address indexed owner)`: Emitted when the application has been declared closed by the owner and the self destruct function has been activated.



## Modifiers

The contract uses the following modifiers to control access to its functions:

-   `olyOwner`: Allows only the owner to call function.
-   `onlySeller(uint _auctionId)`: Allows only seller of item to call function.
-   `auctionExists(uint _auctionId)`: Ensures an auction item exists, otherwise blocks functions call.
-   `open`: Ensures an item has been declared for sale, otherwise blocks function call.


## Getters

The contract provides the following getter functions:

-   `getHighestBid(uint _auctionId)`: Returns the highest bid of an item.
-   `getHighestBidder(uint _auctionId)`: Returns the address of the highest bidder.
-   `getAuctionItemState(uint _auctionId)`: Returns the state of the item. i.e. `bool started` if the auctioning of item has started, `uint endAt` how many days left before auction item closes, `bool sold` if the item has been sold.
-   `getSeller(uint _auctionId)`: Returns the address of the items seller.
-   `getNftId(uint _auctionId)`: Returns the id of the NFT to be sold.
-   `getAuctionItems()`: Returns the total number of items created for sale in auction.
-   `getItemInfo(uint _auctionId)`: Returns every detail on auction item for sale. Master getter.

## Improvement To-do

This is just an simple implementation of the raw idea, still tons of improvement is need to be done

-   Create a simple yet beautiful front end interface using react and nextjs.
-   Host application on vercel.
-   Write function tests.
-   Create an incentive for sellers using my erc20 tokens.

## License

This contract is licensed under the MIT License.

## Contributions
