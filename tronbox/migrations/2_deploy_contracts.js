var MyContract = artifacts.require("./RoyaltiesDistribution.sol");

module.exports = function (deployer) {
  deployer.deploy(MyContract, "TXLAQ63Xg1NAzckPwKHvzw7CSEmLMEqcdj");
};
