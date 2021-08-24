// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.0;


//receiver 0x0c1f1f7b6518216d7414bfeacfb15352f232e874

import "contracts/Escrow.sol"

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
    mapping(uint => address) productIdInStore;

    //用户到产品的映射
    mapping(address => mapping(uint => Product)) stores;
    
    //商品到托管合约的映射
    mapping (uint => address) productEscrow;
    
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
        address payable  highestBidder; 
        uint highestBid;
        uint secondHighestBid;
        uint totalBids;
        ProductStatus status; //商品拍卖状态
        ProductCondition condition; //商品状况
        mapping (address => mapping(bytes32=>Bid)) bids;
        
    }
    
   

    constructor()public{
        productIndex = 0;
    }
    
    //竞价信息
    struct Bid{
        address bidder;//竞价人
        uint productID;//拍卖品ID
        uint value;//发送的ETH数目
        bool revealed;//是否揭示
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
            productIdInStore[productIndex]=msg.sender;
    }

    //获取商品信息
    function getProduct(uint _productId)view public returns(uint, string memory, string memory, string memory, string memory, uint, uint, uint,  ProductStatus , ProductCondition ) {
        Product memory product = stores[productIdInStore[_productId]][_productId];
        return (product.id, product.name, product.category, product.imageLink, product.descLink, product.auctionStartTime,product.auctionEndTime, product.startPrice, product.status, product.condition);
    }

    //竞拍出价
    function bid(uint _productId,bytes32 _bid)payable public returns(bool){
        Product storage product = stores[productIdInStore[_productId]][_productId];
        require(block.timestamp >=product.auctionStartTime);
        require(block.timestamp <=product.auctionEndTime);
        require(msg.value > product.startPrice);
        require(uint(product.bids[msg.sender][_bid].bidder)==0);
        product.bids[msg.sender][_bid] = Bid(msg.sender,_productId,msg.value,false);
        product.totalBids +=1;
        return true;
    }
    
    //竞拍揭示出价
    function revealBid(uint  _productId,string memory _amount,string memory _secret)public{
        Product storage product = stores[productIdInStore[_productId]][_productId];
        require(block.timestamp >=product.auctionEndTime);
        bytes32 sealedBid = keccak256(abi.encodePacked(_amount,_secret));
        Bid memory bidInfo = product.bids[msg.sender][sealedBid];
        require(bidInfo.bidder>address(0),"Bidder not exist.");
        require(bidInfo.revealed==false,"Bid is revealed");
        uint refund;
        uint amount = stringToUint(_amount);
        //发送ether小于出价，则退回发送的代币
        if(bidInfo.value < amount){
            refund = bidInfo.value;
        }else{
        //首次出价
            if(product.highestBidder==address(0)){
                product.highestBidder = msg.sender;
                product.highestBid = amount;
                product.secondHighestBid = product.startPrice;
                refund = bidInfo.value - amount;
            }else{
                if(amount >product.highestBid){
                    //出价高于最高价
                    product.secondHighestBid = product.highestBid;
                    product.highestBidder.transfer(product.highestBid);
                    product.highestBid = amount;
                    product.highestBidder = msg.sender;
                    refund = bidInfo.value - amount;
                }else if(amount>product.secondHighestBid){
                    //出价介于最高价和第二高价之间
                    product.secondHighestBid = amount;
                    refund = bidInfo.value;
                    
                }else{
                    //出价低于第二高价
                    refund =  bidInfo.value;              
                }
            }
        }
        if(refund >0){
            msg.sender.transfer(refund);
        }
        product.bids[msg.sender][sealedBid].revealed = true;
    }
    //字符串转uint
    function stringToUint(string memory s)private pure returns(uint){
        bytes memory b = bytes(s);
        uint result=0;
        for(uint i = 0;i < b.length; i++){

            //0-9
            uint8 uint_b = uint8(b[i]);
            if(uint_b >= 48 && uint_b <= 57){
                result = result * 10 + (uint_b-48);

            }
        }
        return result;
    }
    //最高出价人信息
    function highetBidderInfo(uint _productId)public view returns(address,uint,uint){
        Product memory product = stores[productIdInStore[_productId]][_productId];
        return (product.highestBidder,product.highestBid,product.secondHighestBid);
    }
    //获取拍卖总次数
    function totalBids(uint _productId)public view returns(uint){
        Product memory product = stores[productIdInStore[_productId]][_productId];
        return product.totalBids;
    }
    
    
    function finalizeAuction(uint _productId)public{
        Product memory product = stores[productIdInstore[_productId][_productId]];
        require(now > product.auctionEndTime);
        require(product.status==ProductStatus.Open);
        require(product.highestBidder !=msg.sender);
        require(productIdInStore[_productId]!=msg.sender);

        if(product.totalBids == 0){
            product.status = ProductStatus.Unsold;
        }else{
            Escrow escrow = (new Escrow).value(product.secondHighestBid)(_productId,product.highestBidder,productIdInStore[_productId],msg.sender);
            productEscrow[_productId] = address(escrow);
            product.status = ProductStatus.Sold;

            uint refund = product.highestBid - product.secondHighestBid;
            product.highestBidder.transfer(refund);
        }
        stores[productIdInStore[_productId][_productId]]=product;

    }

    function escrowAddressForProduct(uint _productId)public view resturns(address){
        return productEscrow[_productId];
    }

    function escrowInfo(uint _productId)public view returns(address,address,address,bool,uint,uint){
        return Escrow(productEscrow[_productId]).escrowInfo();
    }

    //释放资金
    function releaseAmountToSeller(uint _productId)public{
        Escrow(productEscrow[_productId]).releaseAmountToSeller(msg.sender);
    }

    //退回资金
    function refundAmountToBuyer(uint _productId)public{
        Escrow(productEscrow[_productId]).refundAmountToBuyer(msg.sender);
    }

}
