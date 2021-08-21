Eutil = require('ethereumjs-util');
ProductStore = artifacts.require("../../contracts/ProductStore.sol");

module.exports = function(callback) {
	current_time = Math.round(new Date() / 1000);
	amt_1 =  web3.utils.toWei("1", 'ether');
	ProductStore.deployed().then(function(i) {i.addProductToStore('iphone 6', 'Cell Phones & Accessories', 'QmRQJ2vStY1ZrGs6hft3WGi5y8UcKaJe2bEr7ayActQAsd', 'QmTLr5Nw7U9xxqDcrx7bYZa27fhbTfB5FrxoFZVzZvTw6y', current_time, current_time + 200, 2*amt_1, 0).then(function(f) {console.log(f)})});
	ProductStore.deployed().then(function(i) {i.addProductToStore('iphone 6 plus', 'Cell Phones & Accessories', 'QmbwvNNfuHUAXsR2hSruBTh7EjCACGw2tYxh3NGHzbFbWZ', 'QmWeysTWsbGfawRNsprZNmeW3v88Ho2RGh3Smi36BwSLCu', current_time, current_time + 400, 3*amt_1, 1).then(function(f) {console.log(f)})});
	ProductStore.deployed().then(function(i) {i.addProductToStore('iphone 5', 'Cell Phones & Accessories', 'QmbwvNNfuHUAXsR2hSruBTh7EjCACGw2tYxh3NGHzbFbWZ', 'QmWeysTWsbGfawRNsprZNmeW3v88Ho2RGh3Smi36BwSLCu', current_time, current_time + 14, amt_1, 0).then(function(f) {console.log(f)})}); 
	ProductStore.deployed().then(function(i) {i.addProductToStore('iphone 5s', 'Cell Phones & Accessories', 'QmbwvNNfuHUAXsR2hSruBTh7EjCACGw2tYxh3NGHzbFbWZ', 'QmWeysTWsbGfawRNsprZNmeW3v88Ho2RGh3Smi36BwSLCu', current_time, current_time + 86400, 4*amt_1, 1).then(function(f) {console.log(f)})});
	ProductStore.deployed().then(function(i) {i.addProductToStore('iphone 7', 'Cell Phones & Accessories', 'QmbwvNNfuHUAXsR2hSruBTh7EjCACGw2tYxh3NGHzbFbWZ', 'QmWeysTWsbGfawRNsprZNmeW3v88Ho2RGh3Smi36BwSLCu', current_time, current_time + 86400, 5*amt_1, 1).then(function(f) {console.log(f)})});
	ProductStore.deployed().then(function(i) {i.addProductToStore('Jeans', 'Clothing, Shoes & Accessories', 'QmbwvNNfuHUAXsR2hSruBTh7EjCACGw2tYxh3NGHzbFbWZ', 'QmWeysTWsbGfawRNsprZNmeW3v88Ho2RGh3Smi36BwSLCu', current_time, current_time + 86400 + 86400 + 86400, 5*amt_1, 1).then(function(f) {console.log(f)})});
	ProductStore.deployed().then(function(i) {i.productIndex.call().then(function(f){console.log(f)})});
}