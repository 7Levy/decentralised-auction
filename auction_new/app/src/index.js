import {default as Web3} from "web3";
import {default as contract} from "truffle-contract"
import product_store_artifacts from '../../build/contracts/ProductStore.json'

var ProductStroe = contract(product_store_artifacts);

var ipfsApi = require('ipfs-http-client')

var ipfs = ipfsApi({host:'localhost',port:'5001',protocol:'http'});


window.App = {
  start : function(){
    var self = this;
  }
}

window.addEventListener('load',function(){
  if(typeof web3 !=undefined){
    window.web3 = new Web3(web3.currentProvider);
  }else{
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));
  }
  App.start();
});