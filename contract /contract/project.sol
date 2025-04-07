# Contract-39-Game-Item-Marketplace
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GameItemMarketplace {
    address public owner;

    struct Item {
        uint id;
        string name;
        string metadataURI;
        uint price;
        address payable seller;
        address buyer;
        bool sold;
    }

    uint public itemCount;
    mapping(uint => Item) public items;

    event ItemListed(uint indexed itemId, string name, uint price, address seller);
    event ItemPurchased(uint indexed itemId, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function listItem(string memory _name, string memory _metadataURI, uint _price) public {
        require(_price > 0, "Price must be greater than 0");

        itemCount++;
        items[itemCount] = Item(
            itemCount,
            _name,
            _metadataURI,
            _price,
            payable(msg.sender),
            address(0),
            false
        );

        emit ItemListed(itemCount, _name, _price, msg.sender);
    }

    function buyItem(uint _itemId) public payable {
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "Item does not exist");
        require(msg.value == item.price, "Incorrect amount sent");
        require(!item.sold, "Item already sold");
        require(msg.sender != item.seller, "Seller cannot buy their own item");

        item.seller.transfer(msg.value);
        item.buyer = msg.sender;
        item.sold = true;

        emit ItemPurchased(_itemId, msg.sender);
    }

    function getItem(uint _itemId) public view returns (Item memory) {
        require(_itemId > 0 && _itemId <= itemCount, "Invalid item ID");
        return items[_itemId];
    }

    function fetchAllItems() public view returns (Item[] memory) {
        Item[] memory result = new Item[](itemCount);
        for (uint i = 1; i <= itemCount; i++) {
            result[i - 1] = items[i];
        }
        return result;
    }
}
