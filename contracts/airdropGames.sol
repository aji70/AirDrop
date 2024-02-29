// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    // function name() external view returns (string memory);
    // function symbol() external view returns (string memory);
    // function decimals() external view returns (uint8);
    // function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    // function approve(address _spender, uint256 _value) external returns (bool success);
    // function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
interface IAjiVRFv2Consumer {
   function requestRandomWords() external returns (uint256 requestId);
   function setNum(uint32 _num) external ;
   function Winners() external view returns(uint [] memory _winners);   
    
}

contract AirdropGames{

    struct Participant{
        uint id;
        uint points;
        uint gamesParticipatedCount;
        uint reward;
        uint raffelNumber;
    }

        uint[] public winnigNumber;

    uint participantsCount;
    mapping (address => Participant) public participants;
    mapping (address => uint)  guessGameScore;
    mapping (address => bool)  followTwitter;
    mapping (address => bool)  hasRegistered;
    mapping (address => bool)  connectlink;
    mapping (address => bool)  guessGame;
    mapping (address => uint)  airDropRaffelNumber;
     mapping (address => bool)  gottenRaffelnum;
    mapping (uint => Participant)  airDropRaffelParticipant;
    uint public deadline = block.timestamp  + 3600;
    
    event rewardClaimed(address, string, uint, string);

    uint rewardCount;

    address ajidokwuToken = 0xb9F69472A23fb0C20fB3Cb699eF8746eD43488e1;
    address chainLink = 0x2f382911995146c5B721b7418f9D338BAB843A9d;

    Participant[] public participantsArray;
            address owner = msg.sender;


    function register() external {
        require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
        Participant storage newParticipant = participants[msg.sender];
        require(!hasRegistered[msg.sender], "Registered already");
        uint _id = participantsCount + 1;
        newParticipant.id = _id;
        newParticipant.points = 0;
        hasRegistered[msg.sender] = true;
        guessGameScore[msg.sender] = 5;

    }

    function guessTheNumber(uint _guess) external  returns(string memory answer)  {
        require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
        require(hasRegistered[msg.sender], "Only Registered accounts can apply");
        Participant storage newParticipant = participants[msg.sender];
        participantsArray.push(newParticipant);   
        participantsCount++;
        require(!guessGame[msg.sender], "You have played already");
        
        
        string memory lost = "You Have Lost The game";
        uint number = 2;
        if ( guessGameScore[msg.sender] < 1){
            guessGame[msg.sender] = true;
            newParticipant.gamesParticipatedCount +=1;
            newParticipant.points += 100;
            return (lost);
        }
        else if(_guess == number){
            guessGame[msg.sender] = true;
            newParticipant.gamesParticipatedCount +=1;
            uint points = 300;
            newParticipant.points += newParticipant.points + (points *  guessGameScore[msg.sender]);
            return("Congratulations you Won");
        }
        else if(_guess > number){
             guessGameScore[msg.sender]--;
            return("Too High");
        }
         else if(_guess < number){
             guessGameScore[msg.sender]--;
            return("Too Low");
        }
        
    }

    function followUsOnTwitter() external {
        require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
        require(hasRegistered[msg.sender], "Only Registered accounts can apply");
        require(!followTwitter[msg.sender], "Already following");
        Participant storage newParticipant = participants[msg.sender];
        newParticipant.gamesParticipatedCount +=1;
        followTwitter[msg.sender] =true;
        newParticipant.points += 100;
    }

       function connectLink() external {
        require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
        require(hasRegistered[msg.sender], "Only Registered accounts can apply");
        require(!connectlink[msg.sender], "Already following");
        Participant storage newParticipant = participants[msg.sender];
        newParticipant.gamesParticipatedCount +=1;
        connectlink[msg.sender] =true;
        newParticipant.points += 200;
    }

    function getAirdropRaffelNumber() external returns (uint Raffel_ID) {
        require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
        require(!gottenRaffelnum[msg.sender], "Already have Raffel Number");
        Participant storage newParticipant = participants[msg.sender];
        if(rewardCount <=10){
            require(newParticipant.gamesParticipatedCount >= 2, "Not yet Eligible");
            rewardCount++;
            airDropRaffelNumber[msg.sender] = rewardCount;
            newParticipant.raffelNumber = rewardCount;
            gottenRaffelnum[msg.sender] = true;
            airDropRaffelParticipant[rewardCount] = newParticipant;
            return (rewardCount);

        }
    }

    function getPoints() external view returns(uint){
        Participant storage newParticipant = participants[msg.sender];
        return(newParticipant.points);
    }


    function randomWinners() external  returns(uint [] memory){
        uint[] memory arr = IAjiVRFv2Consumer(chainLink).Winners();
        for(uint i = 0; i < arr.length; i++){
           uint a = arr[i];
           uint b = a % 10;
            winnigNumber.push(b);
            }
                 
        return (winnigNumber);
     }

    function airdropRewardCalculation() external  returns(uint){
        Participant storage newParticipant = participants[msg.sender];
        require(gottenRaffelnum[msg.sender], "You do not qualify for reward");
        uint reward = newParticipant.points * 100000;
        newParticipant.points = 0;
        newParticipant.reward += reward;
        return(reward) ;          
    }

   function claimReward() external returns (string memory status) {
    Participant storage newParticipant = participants[msg.sender];
    require(gottenRaffelnum[msg.sender], "You do not qualify for reward");
    require(newParticipant.reward > 0, "Reward Claimed");

    for (uint i = 0; i < winnigNumber.length; i++) {
        if (winnigNumber[i] == airDropRaffelNumber[msg.sender]) {
            uint amount = newParticipant.reward;
            newParticipant.reward = 0;

            // Check if the contract has enough tokens to transfer
            require(IERC20(ajidokwuToken).balanceOf(address(this)) >= amount, "Contract does not have enough tokens");

            // Update the participant's reward before transferring to reduce gas costs
            IERC20(ajidokwuToken).transfer(msg.sender, amount);

            emit rewardClaimed(msg.sender, "claimed", amount, "successfully");
            return "CONGRATULATIONS";
        }
    }

    // No winning number matched, participant did not win
    revert("No reward won, try again next time");
}


    function timeLeft() external  view returns(uint TimeLeftIs){
        require(deadline > block.timestamp, "TIME UP");
        uint tL = deadline - block.timestamp;
        return tL;
    }
}