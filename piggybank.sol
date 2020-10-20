pragma solidity >=0.4.22 <0.7.0;

contract PiggyBank{
    
    // Structure for the Stakeholder
    // id - stakeholder id (for iterating over signatures)
    // addr - stakeholder account address
    // signed - fund release authorization
    struct Stakeholder {
        uint id;
        address addr;
        bool signed;
    }
    
    uint private minVotes;
    mapping(address => Stakeholder) private stakeholderStorage;
    address[] private stakeholderIndex;
    address payable constant private destination = 0x357573E1b99293Bc09b7392B560b3C336c22690C;
    
    function deposit() public payable{
        // In case this is the user's first deposit,
        // add the user info to the stakeholders storage and
        // re-calculates minVotes
        if(stakeholderStorage[msg.sender].id == 0){
            
            stakeholderIndex.push(msg.sender);
            
            stakeholderStorage[msg.sender].id = stakeholderIndex.length;
            stakeholderStorage[msg.sender].addr = msg.sender;
            stakeholderStorage[msg.sender].signed = false;
            
            uint div = stakeholderIndex.length / 2;
            uint rem = stakeholderIndex.length % 2;
        
            minVotes = div;
        
            if (rem > 0){
                minVotes++;
            }
        }
    }

    // Verify if the stakeholder approval is
    // bigger than the minimum ammount of signatures/votes needed.
    function checkApproval() private view returns (bool approved) {
        
        uint voteCount = 0;
        
        for (uint i=0; i<stakeholderIndex.length; i++) {
            if (stakeholderStorage[stakeholderIndex[i]].signed)
                voteCount += 1;
        }
        
        if(voteCount >= minVotes){
            return true;
        }
        else{
            return false;
        }
    }
    
    // Approves the withdrawal
    // in case checkApproval passes, withdraws the funds.
    // Returns false in case not enough approvals are gathered.
    function approveWithdrawal() public returns (bool withdrawal){
        require(stakeholderStorage[msg.sender].id > 0, "Account did not deposit any funds.");
        require(stakeholderStorage[msg.sender].signed == false, "Account already approved the withdrawal");
        
        stakeholderStorage[msg.sender].signed = true;
        
        if(checkApproval()){
            return execWithdrawal();
        }
        
        return false;
    }
    
    // Removes stakeholder approval
    function removeApproval() public {
        require(stakeholderStorage[msg.sender].id > 0, "Account did not deposit any funds.");
        require(stakeholderStorage[msg.sender].signed == true, "Account did not approve the withdrawal");
        
        stakeholderStorage[msg.sender].signed = false;
        return;
    }
    
    // Transfers all funds to the destination account
    function execWithdrawal() private returns (bool withdrawal){
        destination.transfer(address(this).balance);
        return true;
    }
    
    
    
}
    
    