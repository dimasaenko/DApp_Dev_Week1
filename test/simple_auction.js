var SimpleAuction = artifacts.require("./SimpleAuction.sol");

contract('SimpleAuction', function(accounts) {
    var auctionInstance;
    it("Should be able to post lot", function() {
        auctionInstance = SimpleAuction.deployed().then((instance) => {
            auctionInstance = instance;
            return auctionInstance.createLot("aaaa", "500", "50");
        }).then((result) => {
            var eventArgs = result.logs[0].args;
            assert.equal(eventArgs.lotId.toNumber(), 1, "First lot id should be 1");
            assert.equal(eventArgs.name, "aaaa", "Name lot id should be 'aaaa'");
            assert.equal(eventArgs.price.toNumber(), 500, "Price lot id should 500");
            assert.equal(eventArgs.minBid.toNumber(), 50, "MinBid lot id should 50");
        });
    });
});
