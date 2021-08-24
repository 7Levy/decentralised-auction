// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;


contract Escrow {
    uint public productId;
    address public buyer;
    address public seller;
    address public arbiter;
    uint public amount;
    bool public fundDisbursed;
    mapping(address => bool)releaseAmount;
    mapping(address => bool)refundAmount;
    uint public releaseCount;
    uint public refundCount;


    event CreateEscrow(uint _productId, address _buyer, address _seller, address _arbiter);
    event UnlockAmount(uint _productId, string _operation, address _operator);
    event DisburseAmount(uint _productId, uint _amount, address _beneficiary);

    constructor(uint _productId,address _buyer,address _seller,address _arbiter) payable public{
        productId = _productId;
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
        amount = msg.value;
        fundDisbursed = false;
        emit CreateEscrow(_productId,_buyer,_seller,_arbiter);
    }


    //托管资产信息
    function escrowInfo()view public returns(address,address,address,bool,uint,uint){
        return(buyer,seller,arbiter,fundDisbursed,releaseCount,refundCount);
    }

    //释放资金(托管=>卖家)
    function releaseAmountToSeller(address caller) public{
        require(!fundDisbursed);
        if ((caller==buyer || caller == seller || caller==arbiter)&&releaseAmount[caller]!=true){
            releaseAmount[caller] = true;
            releaseCount +=1;
            emit UnlockAmount(productId,"release",caller);
        }
        if(releaseCount==2){
            seller.transfer(amount);
            fundDisbursed = true;
            emit DisburseAmount(productId,amount,seller);
        }
        
    }

    //退回资金(托管=>买家)
    function refundAmountTobuyer(address caller)public{
        require(!fundDisbursed);
        if ((caller==buyer || caller == seller || caller==arbiter)&&refundAmount[caller]!=true){
            refundAmount[caller] = true;
            refundCount +=1;
            emit UnlockAmount(productId,"refund",caller);
        }
        if(refundCount==2){
            buyer.transfer(amount);
            fundDisbursed = true;
            emit DisburseAmount(productId,amount,buyer);
        }
    }
}