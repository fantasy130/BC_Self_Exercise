var trade = artifacts.require("Trade");

module.exports = function(deployer) {
  deployer.deploy(trade,"0xbe1cb8986dd656259a46e0941e0e43ccecebc674", "2");
};
