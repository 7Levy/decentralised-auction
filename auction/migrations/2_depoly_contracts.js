const ProductStore = artifacts.require("ProductStore");

module.exports = function (deployer) {
  deployer.deploy(ProductStore);
};
