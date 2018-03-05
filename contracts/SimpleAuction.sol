pragma solidity ^0.4.19;

import "./SimpleAuctionInterface.sol";

contract SimpleAuction is AuctionInterface {

    // ============
    // Marketplace:
    // ============

    uint constant expiredIn = 500;

    uint constant minBidDiff = 10;

    /**
     * @notice this mapping used for storing lots
     */
    mapping (uint => Lot) public lots;

    /**
    * @notice Increment ID for storing lots in the mapping
    */
    uint public increamentLotId;

    /**
    * @notice  Checks if lot exists
    * @param   _lotID Integer identifier associated with target lot
    */
    modifier lotExists(uint _lotID) {
        require(lots[_lotID].price > 0);
        _;
    }

    /**
    * @notice  Checks if sender is lot owner
    * @param   _lotID Integer identifier associated with target lot
    */
    modifier lotOwner(uint _lotID) {
        require(lots[_lotID].price > 0 && lots[_lotID].owner == msg.sender);
        _;
    }

    /**
    * @notice Lot structure
    */
    struct Lot {
        string name;
        address owner;
        uint price;
        uint minBid;
        uint currentBid;
        address bidder;
        uint expiredAt;
        bool isProcessed;
    }

    event LotCreated(uint lotId, string name, uint price, uint minBid);

    /**
     * @notice  Creates a lot.
     * @param   _name The lot name.
     * @param   _price Amount (in Wei) needed to buy the lot immediately
     * @param   _minBid Amount (in Wei) needed to place a bid.
     */
    function createLot(string _name, uint _price, uint _minBid) public {
        require(_price > 0 && _minBid <= _price);
        increamentLotId += 1;
        lots[increamentLotId] = Lot({
            name : _name,
            owner : msg.sender,
            price : _price,
            minBid : _minBid,
            currentBid : 0,
            bidder : address(0),
            expiredAt : block.number + expiredIn,
            isProcessed : false
        });
        LotCreated(increamentLotId, _name, _price, _minBid);
    }

    /**
     * @notice  Removes lot, which has no bids.
     * @param   _lotID Integer identifier associated with target lot
     */
    function removeLot(uint _lotID) lotExists(_lotID) public {
        require(lots[_lotID].owner == msg.sender);
        require(lots[_lotID].bidder == address(0));
        delete lots[_lotID];
    }

    /**
     * @notice  Places a bid. Contract should return the wei value to previous
     *          bidder
     * @param  _lotID Integer identifier associated with target lot
     */
    function bid(uint _lotID) payable lotExists(_lotID) public {
        Lot memory lot = lots[_lotID];
        require(lot.expiredAt > block.number
            && lot.isProcessed == false);

        if (msg.value >= lot.price) {
            placeBid(_lotID);
            lots[_lotID].isProcessed = true;
            return;
        }

        if (lot.currentBid == 0 && msg.value >= lot.minBid) {
            placeBid(_lotID);
            return;
        }

        require(lot.currentBid > 0 && msg.value - minBidDiff >= lot.currentBid);
        placeBid(_lotID);
    }

    /**
    * @notice  Returns previous bid, saves current bid and address
    * @param   _lotID Integer identifier associated with target lot
    */
    function placeBid(uint _lotID ) private {
        if (lots[_lotID].currentBid > 0) {
            lots[_lotID].bidder.transfer(lots[_lotID].currentBid);
        }
        lots[_lotID].currentBid = msg.value;
        lots[_lotID].bidder = msg.sender;
    }

    /**
     * @notice  Resolves the lot status if it's time is passed. Anyone should
     *          call the function when the lot ends to explicitly mark the lot
     *          as completed and transfer bid amount to the lot owner.
     * @param   _lotID Integer identifier associated with target lot
     */
    function processLot(uint _lotID) lotExists(_lotID) public {
        require(lots[_lotID].expiredAt > block.number);
        lots[_lotID].isProcessed = true;
    }

    /**
     * @notice  Shows the last bid owner (bidder) address.
     * @param   _lotID Integer identifier associated with target lot
     * @return  Bidder address
     */
    function getBidder(uint _lotID) constant lotExists(_lotID) public returns (address) {
        return lots[_lotID].bidder;
    }

    /**
     * @notice  Determines if lot is ended.
     * @param   _lotID Integer identifier associated with target lot
     * @return  Boolean indication of whether the lot is ended.
     */
    function isEnded(uint _lotID) constant public returns (bool) {
        return lots[_lotID].expiredAt > block.number && lots[_lotID].isProcessed;
    }

    /**
     * @notice  Determines if lot is processed.
     * @param   _lotID _lotID Integer identifier associated with target lot
     * @return  Boolean indication of whether the lot is processed.
     */
    function isProcessed(uint _lotID) constant public returns (bool) {
        return lots[_lotID].isProcessed;
    }

    /**
     * @notice  Determines if lot exists.
     * @param   _lotID Integer identifier associated with target lot
     * @return  Boolean indication of whether the lot exists.
     */
    function exists(uint _lotID) constant public returns (bool) {
        return lots[_lotID].price > 0;
    }
}
