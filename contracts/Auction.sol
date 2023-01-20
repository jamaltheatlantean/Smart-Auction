// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* --> INTERFACE <-- */

import "./IERC721.sol";

/* --> ERRORS <-- */

error Auction__AppNotStarted();
error Auction__NotStarted();
error Auction__SaleOver();
error Auction__ItemSold();
error Auction__NotOwner();
error Auction__NoBalance();
error Auction__NotSeller();
error Auction__ItemNonExistent();

contract Auction {

    /* --> STATE VARIABLES <-- */

    address public owner; 
    uint public totalItems = 0; // Amount of items created for auction
    uint public constant TAX_FEE = 1e5; // fee for registration
    
    // for starting application ! auction
    bool public appStarted;
    bool public appClosed;
    
    mapping(address => uint) public bids;
    
    struct AuctionItem {
        address payable seller; // seller of item
        address highestBidder; // highest bidder
        uint highestBid; // highest bid
        address nft; //  address of NFT
        uint nftId; // NFT id
        uint endAt; // expiration period on item 
        bool started; // auction started = true
        bool sold;  // item sold = true
    }
    AuctionItem[] public auctionItems;

    /* --> EVENTS <-- */
    
    event AuctionOpen(address indexed owner);
    event ItemCreated(address indexed seller, uint timestamp, uint _auctionId);
    event AuctionStarted(uint indexed _auctionId);
    event ItemBidIncreased(address indexed sender, uint bid);
    event BalanceClaimed(address indexed sender, uint bal);
    event ItemSold(address winner, uint amount);
    event AuctionClosed(address indexed owner);

    /* --> MODIFIERS <-- */
    
    modifier onlyOwner {
        if(msg.sender != owner)
            revert Auction__NotOwner();
        _;
    }

    modifier auctionExists(uint _auctionId) {
    if(_auctionId > auctionItems.length)
        revert Auction__ItemNonExistent();
        _;
    }

    modifier open {
        if(appStarted != true) 
            revert Auction__AppNotStarted();
        _;
    }

    modifier onlySeller(uint _auctionId) {
        AuctionItem storage auction = auctionItems[_auctionId];
        if(msg.sender != auction.seller) 
            revert Auction__NotSeller();
        _;
    }

    /* --> CONSTRUCTOR <-- */
    
    constructor() {
        owner = payable(msg.sender);
    }
    
    /* --> PUBLIC FUNCTIONS <-- */
    
    // function for generally starting up the auction application.
    function startApp() public onlyOwner {
        appStarted = true;
        emit AuctionOpen(msg.sender);
    }

    function register(address _nft, uint _nftId, uint highestBid, address payable seller) public payable open {
        require(msg.value >= TAX_FEE, "warning: insufficient registration funds");
        auctionItems.push(AuctionItem({
            seller: payable(seller),
            nft: _nft,
            nftId: _nftId,
            highestBidder: address(0),
            highestBid: highestBid,
            endAt: block.timestamp + 7 days,
            started: false,
            sold: false
        }));
        totalItems += 1;
        IERC721(_nft).transferFrom(seller, address(this), _nftId);
        // emit event
        emit ItemCreated(msg.sender, block.timestamp, totalItems+1);
    }

    function startAuction(uint _auctionId) public auctionExists(_auctionId) onlySeller(_auctionId) open {
        AuctionItem storage auction = auctionItems[_auctionId];
        require(auction.sold != true, "Item sold");
        auction.started = true;
        // emit event
        emit AuctionStarted(_auctionId);
    }

    function bid(uint _auctionId) public auctionExists(_auctionId) payable open returns (bool)  {
        AuctionItem storage auction = auctionItems[_auctionId];
        if(!auction.started)
            revert Auction__NotStarted();
        if(auction.sold)
            revert Auction__ItemSold();
        if(block.timestamp >= auction.endAt)
            revert Auction__SaleOver();
        require(msg.value > auction.highestBid, "Bid higher");
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        if(auction.highestBidder != address(0)) {
            bids[auction.highestBidder] += auction.highestBid;
        }
        // emit event
        emit ItemBidIncreased(msg.sender, msg.value);
        return true;
    }

    /* --> EXTERNAL FUNCTIONS <-- */
    
    function claimBalance(uint _auctionId) external auctionExists(_auctionId) {
        AuctionItem storage auction = auctionItems[_auctionId];
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        if(msg.sender != auction.highestBidder) {
            payable(msg.sender).transfer(bal);
        } else {
        revert Auction__NoBalance();
        }
        // emit event
        emit BalanceClaimed(msg.sender, bal);
    }
        
    function transferItem(address nft, uint nftId, uint _auctionId) external onlySeller(_auctionId) open auctionExists(_auctionId) {
        AuctionItem storage auction = auctionItems[_auctionId];
        require(block.timestamp >= auction.endAt, "warning: Auction not due");
        auction.sold = true;
        if(auction.highestBidder != address(0)) {
            IERC721(nft).safeTransferFrom(address(this), auction.highestBidder, nftId);
        auction.seller.transfer(auction.highestBid);
        } else {
            // transfer item back to seller
            IERC721(nft).safeTransferFrom(address(this), auction.seller, nftId);
        }
        // emit event
        emit ItemSold(auction.highestBidder, auction.highestBid);
    }

    /**
    * @dev function transfers ownership for repossesion of contract.
    */
    function transferOwnership(address payable newOwner) external {
        require(!appStarted, "warning: app already started");
        require(newOwner != address(0), "invalid address");
        owner = payable(newOwner);
    }

    function closeApplication() external onlyOwner {
        require(address(this).balance == 0, "warning: Funds still in application");
        appClosed = true;
        selfdestruct(payable (owner));
        emit AuctionClosed(msg.sender);
    }

    /* --> GETTER FUNCTIONS <-- */
    
    function getHighestBid(uint _auctionId) public 
    view
    returns (uint highestBid) {
        AuctionItem storage auction = auctionItems[_auctionId];
        return(auction.highestBid);
    }

    function getHighestBidder(uint _auctionId) public view returns (address highestBidder)
    {
        AuctionItem storage auction = auctionItems[_auctionId];
        return(auction.highestBidder);
    }

    function getAuctionItemState(uint _auctionId) public view returns (bool started, uint endAt, bool sold) {
        AuctionItem storage auction = auctionItems[_auctionId];
        return(auction.started, auction.endAt, auction.sold);
    }

    function getSeller(uint _auctionId) public view returns (address seller) {
        AuctionItem storage auction = auctionItems[_auctionId];
        return(auction.seller);
    }

    function getNftId(uint _auctionId) public view returns (uint nftId) {
        AuctionItem storage auction = auctionItems[_auctionId];
        return(auction.nftId);
    }

    function getAuctionItems() public view returns (AuctionItem[] memory) {
        return auctionItems;
    }

    function getItemInfo(uint _auctionId) public view returns (AuctionItem memory) {
        return auctionItems[_auctionId - 1];
    }

}
