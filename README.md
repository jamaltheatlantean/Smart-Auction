<a name="readme-top"></a>
[![Contributors][contributors-shield]][contributors-url]
[![Issues][issues-shield]][issues-url]
[![LinkedIn][linkedin-shield]][linkedin-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="[https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION](https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION)">
  </a>

<h3 align="center">UPGRADED ENGLISH AUCTION</h3>
  <p align="center">
    Have multiple auctions at once.
    <br />
    <a href="https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION/issues">Report Bug</a>
    ·
    <a href="https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#features">Features</a></li>
    <li><a href="#issues">Issues</a></li>
    <li><a href="#events">Events</a></li>
    <li><a href="#modifiers">Modifiers</a></li>
    <li><a href="#getters">Getters</a></li>
    <li><a href="#improvements">Improvements</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>


<!-- ABOUT THE PROJECT -->
## About The Project

This is a full smart contract for handling multiple auctions of ERC721 tokens. The contract has a self destruct function that can only be called when all items have been sold.
  
  ### Built With

* [![Solidity][Soliditylang.org]][Solidity-url]

  
  <!-- GETTING STARTED -->
## Getting Started

### Prerequisites

* npm
  ```sh
  npm install npm@latest -g
  ```

<!-- INSTALLATION -->
### Installation

1. Get a free API Key at [https://alchemy.com](https://alchemy.com)
2. Clone the repo
   ```sh
   git clone https://github.com/jamaltheatlantean/SPLIT-PAY.git
   ```
3. Install NPM packages
   ```sh
   npm install
   ```
4. Enter your API in `config.js`
   ```js
   const API_KEY = 'ENTER YOUR API';
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>
  
<!-- FEATURES -->
## Features

-   The contract can hold multiple ERC721 tokens and award them to the highestBidder.
-   The contracts ownership can be transferred to a new address incase of need.
-   When a bid has been outbidded the bidder can withdraw his ETH and bid higher.
-   The contract has a self-destruct function that sends all unclaimed funds to the owners address. To prevent loss of unclaimed funds, this function can only be called when there are no funds left in the contract. `require(address(this).balance == 0)`.
  
<!-- ISSUES -->
## Issues
  See the [open issues](https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION/issues) for a full list of proposed features (and known issues).

<!--EVENTS -->
## Events

The contract includes the following events:

-   `event AuctionOpen(address indexed owner)`: Emitted when the application is declared active by the owner.
-   `event ItemCreated(address indexed seller, uint timestamp, uint _auctionId)`: Emitted when an item has been created for auctioning. It emits the seller, time created and it's id which is its place in the array of Auctions.
-   `event AuctionStarted(uint indexed _auctionId)`: Emitted when created item has been declared up for sale by the seller. Starting its 7 days on the auction countdown. It emits the id.
-   `event ItemBidIncreased(address indexed sender, uint bid, uint indexed _auctionId)`: Emitted when the bid on an item has been increased, cancelling out a previous bid. It emits the addrress of the bidder `msg.sender`, the amount bidded, and the id.
-   `event BalanceClaimed(address indexed sender, uint bal)`: Emitted when a bidder claims his outbidded balance from the contract. It emits the bidders address and the amount `bal`.
-   `event ItemSold(address winner, uint amount): Emitted when the 7 days auction is over and the item has been awarded to the highest bidder `highestBidder`. It emits the addrress of the winning bidder and the amount the item sold for.
-   `event AuctionClosed(address indexed owner)`: Emitted when the application has been declared closed by the owner and the self destruct function has been activated.


<!-- MODIFIERS -->
## Modifiers

The contract uses the following modifiers to control access to its functions:

-   `onlyOwner`: Allows only the owner to call function.
-   `onlySeller(uint _auctionId)`: Allows only seller of item to call function.
-   `auctionExists(uint _auctionId)`: Ensures an auction item exists, otherwise blocks functions call.
-   `open`: Ensures an item has been declared for sale, otherwise blocks function call.

<!--GETTERS -->
## Getters

The contract provides the following getter functions:

-   `getHighestBid(uint _auctionId)`: Returns the highest bid of an item.
-   `getHighestBidder(uint _auctionId)`: Returns the address of the highest bidder.
-   `getAuctionItemState(uint _auctionId)`: Returns the state of the item. i.e. `bool started` if the auction of item has started, `uint endAt` how many days left before auction item closes, `bool sold` if the item has been sold.
-   `getSeller(uint _auctionId)`: Returns the address of the items seller.
-   `getNftId(uint _auctionId)`: Returns the id of the NFT to be sold.
-   `getAuctionItems()`: Returns the total number of items created for sale in auction.
-   `getItemInfo(uint _auctionId)`: Returns every detail on auction item for sale. Master getter.

<!-- IMPROVEMENTS -->
## Improvements

This is just an simple implementation of the raw idea, still tons of improvement is need to be done

-   Create a simple yet beautiful front end interface using react and nextjs.
-   Host application on vercel.
-   Write function tests.
-   Create an incentive for sellers using my erc20 tokens.
  
  
<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!--LICENSE -->
## License

This contract is licensed under the MIT License.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

Jamaltheatlantean [Gabriel Isobara]                               
Send me a tweet - [@twitter](https://twitter.com/ThatAtlantean)                                                            

Or write me a mail - jamaltheatlantean@gmail.com

Project Link: [https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION](https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION)

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION.svg?style=for-the-badge
[contributors-url]: https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION/graphs/contributors
[issues-shield]: https://img.shields.io/github/issues/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION.svg?style=for-the-badge
[issues-url]: https://github.com/jamaltheatlantean/UPGRADED-ENGLISH-AUCTION/issues
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/gabriel-isobara
[Soliditylang.org]: https://img.shields.io/badge/solidity-lang-lightgrey
[Solidity-url]: https://soliditylang.org/

