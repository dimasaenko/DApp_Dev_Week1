var Migrations = artifacts.require("./Migrations.sol");
var SimpleAuction = artifacts.require("./SimpleAuction.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(SimpleAuction);
};
