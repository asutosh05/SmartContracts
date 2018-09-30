pragma solidity ^0.4.2;


contract Cashback{
    /**
        For Loging
    */
    event LogTransations(address _address,uint _amount);
    /**
        @notice To deposit Fund
    */
    function despositFund() payable {
        LogTransations(msg.sender,msg.value);
        cashbackHalf(msg.value);
    }
    /**
        @notice For 50% cash bcack
    */
    function cashbackHalf(uint ammount) private{
        msg.sender.send(ammount/2);
        LogTransations(msg.sender,ammount/2);
    }
    
    /**
        @notice For Check funds 
    */
    function checkFunds() constant returns(uint){
        return this.balance;
    }

}
