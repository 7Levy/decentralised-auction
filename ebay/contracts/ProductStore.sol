// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;


//receiver 0x0c1f1f7b6518216d7414bfeacfb15352f232e874


/**
 *产品相关的数据结构
 */
contract ProductStore{
    
    //拍卖状态：可竞价、已拍出、未拍出
    enum ProductStatus{Open,Sold,Unsold}

    //商品状况：新品、二手
    enum ProductCondition{New,Used}
    
    //商品编号
    uint public productIndex;

    //产品到用户映射
    mapping(uint => address) productIDStore;

    //用户到产品的映射
    mapping(address => mapping(uint => Product)) stores;
    
    
    //商品信息
   struct Product {
      uint id; //商品ID
      string name; //商品名
      string category; //商品分类
      string imageLink; //商品图片
      string descLink; //商品描述
      uint auctionStartTime; //商品拍卖开始
      uint auctionEndTime; //商品拍卖结束
      uint startPrice; //初始价格
      address highestBidder; 
      uint highestBid;
      uint secondHighestBid;
      uint totalBids;
      ProductStatus status; //商品拍卖状态
      ProductCondition condition; //商品状况
    }
    constructor()public{
        productIndex = 0;
    }


    //上架商品
    function addProductToStore(string memory _name, string memory _category, string memory _imageLink, string memory _descLink, uint _auctionStartTime,uint _auctionEndTime, uint _startPrice, uint _productCondition) public{
        
        require(_auctionStartTime < _auctionEndTime,"auctionStartTime shouble be earlier than auctionEndTime");
        productIndex += 1;
        Product memory product = Product(
            productIndex, 
            _name, 
            _category,
            _imageLink, 
            _descLink, 
            _auctionStartTime, 
            _auctionEndTime,
            _startPrice, 
            address(0),
            0,
            0,
            0,
            ProductStatus.Open, 
            ProductCondition(_productCondition)
            );
            stores[msg.sender][productIndex]=product;
            productIDStore[productIndex]=msg.sender;
    }

    //获取商品信息
    function getProduct(uint _productId)view public returns(uint, string memory, string memory, string memory, string memory, uint, uint, uint,  ProductStatus , ProductCondition ) {
        Product memory product = stores[productIDStore[_productId]][_productId];
        return (product.id, product.name, product.category, product.imageLink, product.descLink, product.auctionStartTime,product.auctionEndTime, product.startPrice, product.status, product.condition);
    }
}

//ProductStore.deployed().then(function(i) {i.getProduct.call(1).then(function(f) {console.log(f)})})

//ProductStore.deployed().then(function(i) {i.addProductToStore('iphone 6', 'Cell Phones & Accessories', 'imagelink', 'desclink', current_time, current_time + 200, amt_1, 0).then(function(f) {console.log(f)})});