// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarket is ReentrancyGuard{

    using Counters for Counters.Counter ;
    Counters.Counter private _itemIds;      // number of total items
    Counters.Counter private _itemsSold;    // number of items sold , to later iterate over arrays

    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor(){
        owner = payable(msg.sender);        // sets owner when deployed
    }

    struct MarketItem{                      // struct to store details about the item
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping (uint256 => MarketItem) idToMarketItem;     // maps itemId to its struct

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address payable seller,
        address payable owner,
        uint256 price,
        bool sold
    );                                      // sends event for frontend

    function getListingPrice() public view returns( uint256){
        return listingPrice;                // returns listing price 
    }

    function createMarketItem(address nftContract , uint256 tokenId , uint256 price ) public payable nonReentrant{
        
        require(price > 0.1 ether , "Price must be atleast 0.1 Matic");
        require( msg.value == listingPrice , "Price must be equal to listing price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        // creates a new market item mapped to its itemid
        idToMarketItem[itemId] = MarketItem(
            itemId, nftContract , tokenId , payable(msg.sender) , payable(address(0)),price,false
        );

        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);    // transfers item from owner to contract

        emit MarketItemCreated(itemId, nftContract, tokenId, payable(msg.sender) , payable(address(0)), price, false);

    }

    function buyMarketItem( address nftContract ,  uint256 itemId) public payable nonReentrant{
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require( msg.value == price , "Send asking price in order to purchase item");

        idToMarketItem[itemId].seller.transfer(msg.value);          // sends price of token to seller
        IERC721(nftContract).safeTransferFrom(address(this)  , msg.sender  , tokenId);  // transfers item from contract to buyer

        idToMarketItem[itemId].owner = payable(msg.sender);     // updates owner in item struct
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();                                 // increments no of sold item
        owner.transfer(listingPrice);                           // sends listing fee to owner

    }

    // function that returns unsold items
    function fetchMarketItems() public view returns( MarketItem[] memory){

        uint256 itemCount = _itemIds.current();                     // total items
        uint256 unsoldItemCount = itemCount - _itemsSold.current(); // items unsold count

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);  // array to store unsolditems in memory
        uint currentIndex = 0 ;

        for( uint i = 1 ; i <= unsoldItemCount; i++){
            if( idToMarketItem[i].owner == address(0)){                // if item unsold // sold to 0 
                uint currentId = idToMarketItem[i].itemId;              // stores id of current item 
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentId] = currentItem;
                currentIndex++;
            }
        }
        return items;
    }


    // function that returns items i have purchased 
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
      uint totalItemCount = _itemIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 1; i <= totalItemCount; i++) {
        if (idToMarketItem[i].owner == msg.sender) {        // counts no of nfts owned by function caller 
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);  // allocated memory for no of nfts array

      for (uint i = 1; i <= totalItemCount; i++) {
        if (idToMarketItem[i].owner == msg.sender) {
          uint currentId = i;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

    // function that returns items i have created
    function fetchItemsListed() public view returns (MarketItem[] memory) {
      uint totalItemCount = _itemIds.current();
      uint itemCount = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {       // same as about but checks if msg.sender is seller of item
          itemCount += 1;
        }
      }

      MarketItem[] memory items = new MarketItem[](itemCount);
      for (uint i = 0; i < totalItemCount; i++) {
        if (idToMarketItem[i + 1].seller == msg.sender) {
          uint currentId = i + 1;
          MarketItem storage currentItem = idToMarketItem[currentId];
          items[currentIndex] = currentItem;
          currentIndex += 1;
        }
      }
      return items;
    }

}
