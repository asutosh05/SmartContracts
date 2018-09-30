pragma solidity ^0.4.2;


contract Shopping{
   
    /* Online Store internals */
    address admin;
    mapping (address => Seller)  sellers;
    mapping (bytes32 => Product)  products;
    mapping (address=> bytes32) soldItems;
    bytes32[]  productsCount;
    /**
        @notice Default constructor
        I am hard coding the admin here for initial stage
    */
    function Shopping(){
        admin=msg.sender;
        
    }
    
     /* Online Store Events */
    event WhiteListSeller(bytes32 message,address seller);
    event SellerAdded(bytes32 message,address seller,bytes32 id);
    event SellerAddProduct(bytes32 message,bytes32 productId,uint256 price,address sellerAddress);
    event CustomerBuyProduct(bytes32 message,bytes32 productId,uint256 price,address buyerAddress);
    
    /**
        @notice to vaidate the address as admin 
    */
    
    modifier isAdmin(){
        if(msg.sender != admin){
            throw;
        }
        _;
    }
    
    modifier isSeller(){
        if(sellers[msg.sender].sellerAddress !=msg.sender){
            throw;
        }
        _;
    }
  
    /**
        @notice every seller has id , address , list of productId and isWhiteList
    */
    
    struct Seller{
        address sellerAddress;
        bytes32 sellerId;
        bytes32[] productIds;
        bool isWhiteList;
    }
    
    /**
        @notice every product has id and price
    */
    
    struct Product{
        bytes32 productId;
        uint256 price;
    }
    
    /**
     @notice Add Seller 
    */
    
    function AddSeller(address _address,bytes32 _id,bool _isWhiteList) isAdmin returns (bool sucess){
        if (_address != admin && _address !=sellers[_address].sellerAddress){
            Seller memory seller=Seller({sellerAddress:_address,sellerId:_id,productIds:new bytes32[](0),isWhiteList:_isWhiteList});
            sellers[_address]=seller;
            SellerAdded("Seller Added Sucess",_address,_id);
            return true;
        }
        SellerAdded("Seller Added Failed ",_address,_id);
        return false;
    }
    
    /**
     @notice To white list Seller Admin only perform the action
    */
    function WhitelistAddress(address _address) isAdmin returns (bool sucess){
        Seller objSeller=sellers[_address];
        if(objSeller.sellerAddress==_address){
            objSeller.isWhiteList=true;
            WhiteListSeller("Seller White Listed Sucess",_address);
            return true;
        }
        WhiteListSeller("Seller White Listed Failed",_address);
        return false;
        
    }
    /**
     @notice To Add Product is seller exists
    */
    function AddProduct(bytes32 _id,uint256 _price) isSeller  returns (bool sucess){
        if(_price>0){
            Product memory product = Product({productId:_id,price:_price});
            products[_id]=product;
            Seller objSeller=sellers[msg.sender];
            objSeller.productIds.push(_id);
            productsCount.push(_id);
            SellerAddProduct("Seller Added Procduct Success",_id,_price,msg.sender);
            return true;
        }
        SellerAddProduct("Seller Added Procduct Fails",_id,_price,msg.sender);
        return false;
        
    }
    //To get all prodct count
    function GetContentCount() constant returns (uint256){
        return productsCount.length;
    }
    
    /**
     @notice By Content Any one can buy now passing correct price in wei only
     * Checking that given price is correct or not 
    */
    function isPriceMatch(bytes32 _id) private returns(bool sucess){
        if(products[_id].price>=msg.value){
            return true;
        }
        return false;
    }
    function BuyContent(bytes32 _id) payable{
        if(isPriceMatch(_id)){
            soldItems[msg.sender]=_id;
            CustomerBuyProduct("Buy Product Sucess",_id,msg.value,msg.sender);
        }
        CustomerBuyProduct("Buy Product faild",_id,msg.value,msg.sender);
        
    }
    
    /**
     * To Check if from address bought a product with this _id
    */
    function BuyCheck(address from ,bytes32 id) constant returns (bool sucess){
        return keccak256(soldItems[from])==keccak256(id);
    }
    
}

