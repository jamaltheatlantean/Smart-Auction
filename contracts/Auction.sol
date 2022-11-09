// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";

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

error Auction__NotEnded();
error Auction__NotEnoughEth();
error Auction__UpkeepNotNeeded();
error Auction__AlreadyTerminated();
error Auction__NotSeller();
error Auction__NotStarted();
error Auction__Sold();

    

contract FlashAuction {
    enum AuctionState {
        OPEN,
        CLOSED
    }

    AuctionState state;

    struct Auction {
        uint8 auctionId;
        address nft;
        uint _nftId;
        bool started;
        bool sold;
    }

    Auction [] public auctions;
    //mapping(uint8 => bool) public auctionExists;
    mapping(uint8 => address) public sellerOf;
    mapping(uint8 => bool) public hasStarted;
    mapping(uint8 => bool) public hasEnded;
    
    mapping(address => bool) public isSeller;
    mapping(address => bool) public isSelller;


    address payable public s_seller;
    mapping(address => uint) public s_highestBidder;
    mapping(address => uint) public s_highestBid;
    address payable public owner;

    uint public endAt;
    bool public started;
    bool public ended;

    uint8 public auctionItems = 0;
    uint public endTime = block.timestamp + 3 minutes; // all auction ends same time

    uint public constant STARTING_BID = 2e2;
    uint public constant TAX_FEE = 2e5;

    mapping(address => uint) public bids;

    modifier onlyOwner() {
        require(owner == msg.sender, "Not owner");
        _;
    }
    
    modifier onlySeller(uint8 auctionId) {
        require(isSeller[msg.sender], "Not s_seller");
        _;
    }

    modifier auctionExists(uint8 auctionId) {
        require(auctionId < auctions.length, "No item in auction");
        _;
    }


    event AuctionStarted(uint indexed auctionId);
    event AuctionCreated(address indexed s_seller, uint256 timestamp, uint8 auctionId);
    event BalanceClaimed(address indexed bidder,uint amount);
    event BidIncreased(address indexed sender, uint bid);
    event AuctionEnded(uint indexed auctionId);

    constructor(
    ) {
        owner = payable(msg.sender);
    }

    /**
    * @dev function transfers ownership if need for repossesion of contract
    */
    function transferOwnership(address payable newOwner) external onlyOwner {
        require(!started, "Auction already started");
        require(newOwner != address(0));
        owner = newOwner;
    }


    function registerNft(address nft, uint8 _nftId
    ) public payable {
        require(msg.value >= TAX_FEE, "Inadequate fee");
        auctions.push(Auction(
            auctionItems+1,
            nft,
            _nftId,
            false,
            false
        ));

        //IERC721(nft).transferFrom(s_seller, address(this), _nftId);
        sellerOf[auctionItems] = msg.sender;
        auctionItems + 1;
        isSeller[msg.sender] = true;
        s_seller = payable(msg.sender);

        emit AuctionCreated(msg.sender, block.timestamp, auctionItems++);
    }

    function startApp() public onlyOwner {
        require(!started, "Application already started");
        started = true;
    }

    function startAuction(uint8 auctionId) public onlySeller(auctionId) auctionExists(auctionId) {
        require(started, "Application not started");
        Auction storage auction = auctions[auctionId];
        auction.started = true;
        require(hasStarted[auctionId] != true, "Auction already started");
        if(hasEnded[auctionId]) {
            revert Auction__Sold();
        }
        endTime = block.timestamp - 60 seconds;

        emit AuctionStarted(auctionId);
    }


    function bid(uint8 auctionId) public payable auctionExists(auctionId) returns (bool) {
        require(!ended, "Application already ended");
        Auction storage auction = auctions[auctionId];
        if(auction.started != true) {
            revert Auction__NotStarted();
        }
        if(auction.sold = true) {
            revert Auction__Sold();
        }
        require(msg.value >= STARTING_BID, "Not up to starting bid");
        require(started, "Application not started");
        if(msg.value <= s_highestBid) {
            revert Auction__NotEnoughEth();
        }

        if (s_highestBidder != address(0)) {
            bids[s_highestBidder] += s_highestBid;
        }

        //endAt = endTime;

        s_highestBidder = msg.sender;
        s_highestBid = msg.value;

        emit BidIncreased(msg.sender, msg.value);

        return true;
    }

    function claimBal(uint8 auctionId) external auctionExists(auctionId) {
        require(!ended);
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);

        emit BalanceClaimed(msg.sender, bal);
    }

    function transferToBidder(address nft, uint8 _nftId, uint8 auctionId) external onlySeller(auctionId) {
        require(hasStarted[auctionId] = true, "Auction not started yet");
        Auction storage auction = auctions[auctionId];
        if(auction.started != true) {
            revert Auction__NotStarted();
        }
        require(block.timestamp >= endAt, "Not time to end");
        require(!ended, "Already ended");

        //ended = true;
        auction.sold = true;
        //s_seller = payable(msg.sender);
        // transfer NFT to highest Bidder
         if(s_highestBidder[auctionId] != address(0)) {
             //IERC721(nft).safeTransferFrom(address(this), s_highestBidder, _nftId);
             s_seller.transfer(s_highestBid);
         } else {
            //IERC721(nft).safeTransferFrom(address(this), s_seller, _nftId);
         }

        emit AuctionEnded(_nftId);
    }

    // Warning: Function terminates bytecode of contract and is irreversible
    function endApp() external onlyOwner {
        ended = true;
        selfdestruct(owner);
    }

    function getCurrentBid() public view returns (uint) {
        return s_highestBid;
    }

    // for recovering testnet eth, comment out during production
    function getBackFunds(address payable addr) public {
        addr.transfer(address(this).balance);
    }


         
}

// ERRORS!!!
// does not keep track of bidders (fixed)
// fails to get the current s_highestBid after update (fixed)
// does not update s_highestBidder in struct (fixed)
// claim bids is stuck in a forever open loop (can't be fixed but irrelevant)

// CHECKS!!!
// retrieves minBid 
// getter functions are effective xcept listed above

// UNFINISHED!!!
// coninues to bid after terminate... write terminate function

// NEW ERRORS
// No new errors but unhandled orange ticks
// fix biddding to match the auction Id. Right now highest bid continues 
// from last auction
// fix that only seller of auctionId can call a the transfer function

// ADDS

// address x = 0x212;
// address myAddress = this;
// if (x.balance < 10 && myAddress.balance >= 10) x.transfer(10);