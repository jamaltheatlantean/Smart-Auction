// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

// =======> ERRORS <==========
error Auction__AppNotStarted();
error Auction__NotStarted();
error Auction__ItemSold();
error Auction__NotOwner();
error Auction__NoBalance();
error Auction__NotSeller();
error Auction__ItemNonExistent();

contract AuctionAuction {

// =======> STATE VARIABLES <========
    address public owner;
    uint public auctionItems = 0;
    uint public constant TAX_FEE = 1e5; // fee for registration

    mapping(uint => address) public sellerOf;
    mapping(address => bool) public isSeller;
    mapping(address => uint) public bids;

    // for starting application ! auction
    bool public appStarted;
    bool public appClosed;
    
        struct Auction {
        address payable seller;
        address highestBidder;
        uint highestBid;
        address nft;
        uint nftId;
        bool started;
        bool sold;
    }
    Auction[] public auctions;

    // events
    event AuctionOpen(address indexed owner);
    event ItemCreated(address indexed seller, uint timestamp, uint auctionId);
    event ItemBidIncreased(address indexed sender, uint bid);
    event BalanceClaimed(address indexed sender, uint bal);
    event ItemSold(address winner, uint amount);
    event AuctionClosed(address indexed owner);

    // =======> MODIFIERS <=======
    modifier onlyOwner {
        if(msg.sender != owner)
            revert Auction__NotOwner();
        _;
    }

    modifier auctionExists(uint _auctionId) {
    if(_auctionId > auctions.length)
        revert Auction__ItemNonExistent();
        _;
    }

    modifier open {
        if(appStarted != true) 
            revert Auction__AppNotStarted();
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    // generally starts up the auction application.
    function startApp() public {
        appStarted = true;
        emit AuctionOpen(msg.sender);
    }


    function register(address _nft, uint _nftId, uint highestBid, address payable seller) public payable open {
        require(msg.value >= TAX_FEE, "warning: insufficient registration funds");
        auctions.push(Auction({
            seller: payable(seller),
            nft: _nft,
            nftId: _nftId,
            highestBidder: address(0),
            highestBid: highestBid,
            started: false,
            sold: false
        }));
        sellerOf[auctionItems] = msg.sender;
        auctionItems += 1;
        isSeller[msg.sender] = true;
        IERC721(_nft).transferFrom(seller, address(this), _nftId);
        // emit event
        emit ItemCreated(msg.sender, block.timestamp, auctionItems+1);
    }

    /**
    * Time Stamp in seconds
    * 86400 = 1 day
        */
    function startAuction(uint _auctionId) public auctionExists(_auctionId) open {
        require(!appClosed, "warning: application closed");
        Auction storage auction = auctions[_auctionId];
        if(msg.sender != auction.seller)
            revert Auction__NotSeller();
        require(auction.sold != true, "Item sold");
        auction.started = true;
        // add endTime later
    }

    function bid(uint _auctionId) public auctionExists(_auctionId) payable open returns (bool)  {
        require(!appClosed, "warning: application closed");
        Auction storage auction = auctions[_auctionId];
        if(!auction.started)
            revert Auction__NotStarted();
        if(auction.sold)
            revert Auction__ItemSold();
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

    function claimBalance(uint _auctionId) external auctionExists(_auctionId) {
        require(!appClosed, "warning: application closed");
        Auction storage auction = auctions[_auctionId];
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
        
    function transferItem(address nft, uint nftId, uint _auctionId) external open {
        require(!appClosed, "warning: application closed");
        Auction storage auction = auctions[_auctionId];
        if(msg.sender != auction.seller)
            revert Auction__NotSeller();
        auction.sold = true;
        if(auction.highestBidder != address(0)) {
            //IERC721(nft).safeTransferFrom(address(this), auction.highestBidder, nftId);
        auction.seller.transfer(auction.highestBid);
        } else {
            // transfer item back to seller
            //IERC721(nft).safeTransferFrom(address(this), auction.seller, nftId);
        }
        // emit event
        emit ItemSold(auction.highestBidder, auction.highestBid);
    }

    /**
    * @dev function transfers ownership if need for repossesion of contract.
    */
    function transferOwnership(address payable newOwner) external {
        require(!appStarted, "warning: close application first");
        require(newOwner != address(0), "invalid address");
        owner = payable(newOwner);
    }

    function closeApplication() external onlyOwner {
        appClosed = true;
        selfdestruct(payable (owner));
        emit AuctionClosed(msg.sender);
    }

    // getter functions
    function getHighestBid(uint _auctionId) public 
    view
    returns (uint highestBid) {
        Auction storage auction = auctions[_auctionId];
        return(auction.highestBid);
    }

    function getHighestBidder(uint _auctionId) public view returns (address highestBidder)
    {
        Auction storage auction = auctions[_auctionId];
        return(auction.highestBidder);
    }

    function getAuctionState(uint _auctionId) public view returns (bool started, bool sold) {
        Auction storage auction = auctions[_auctionId];
        return(auction.started, auction.sold);
    }

    function getItems() public view returns (Auction[] memory) {
        return auctions;
    }

    function getItemInfo(uint _auctionId) public view returns (Auction memory) {
        return auctions[_auctionId - 1];
    }

}
/**
* @ Persoanal Notes: Using enums to represent the auctionState is pointless as there are only
* started and sold booleans.
* Focus more on implementing chainlink keepers
* Open github repo and write a deploy script.
*/

// Personal Notes
// finish using newly created modifier open, and delete requires of the contract being 
// closed. The self destruct function deletes the contracts bytecode.
