// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC20.sol";
// import "./IchainLink.sol";
interface IAjiVRFv2Consumer {
   function RandomNumber1() external view  returns(uint);
    function RandomNumber2() external view  returns(uint);
    function RandomNumber3() external view  returns(uint);
    
}

contract AirdropGames{

    struct Participant{
        uint id;
        uint points;
        uint gamesParticipatedCount;
        uint reward;
        uint raffelNumber;
    }

    uint public randomWinner1;
    uint public randomWinner2;
    uint public randomWinner3;

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
    uint public deadline = block.timestamp  + 9;
    
    event rewardClaimed(address, string, uint, string);

    uint rewardCount;

    address ajidokwuToken = 0xb9F69472A23fb0C20fB3Cb699eF8746eD43488e1;
    address chainLink = 0xE29F4b02667D44BD84741dd3c8C342bda1aD0aF9;

    Participant[] public participantsArray;
            address owner = msg.sender;


    function register() external {
        // require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
        Participant storage newParticipant = participants[msg.sender];
        require(!hasRegistered[msg.sender], "Registered already");
        uint _id = participantsCount + 1;
        newParticipant.id = _id;
        newParticipant.points = 0;
        hasRegistered[msg.sender] = true;
        guessGameScore[msg.sender] = 5;

    }

    function guessTheNumber(uint _guess) external  returns(string memory answer)  {
        // require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
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
        // require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
        require(hasRegistered[msg.sender], "Only Registered accounts can apply");
        require(!followTwitter[msg.sender], "Already following");
        Participant storage newParticipant = participants[msg.sender];
        newParticipant.gamesParticipatedCount +=1;
        followTwitter[msg.sender] =true;
        newParticipant.points += 100;
    }

       function connectLink() external {
        // require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
        require(hasRegistered[msg.sender], "Only Registered accounts can apply");
        require(!connectlink[msg.sender], "Already following");
        Participant storage newParticipant = participants[msg.sender];
        newParticipant.gamesParticipatedCount +=1;
        connectlink[msg.sender] =true;
        newParticipant.points += 200;
    }

    function getAirdropRaffelNumber() external returns (uint Raffel_ID) {
        // require(deadline > block.timestamp, "TIME UP CAN NO LONGER GET REWARDS");
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


    function randomWinners() external  returns(uint, uint, uint){

         randomWinner1 = IAjiVRFv2Consumer(chainLink).RandomNumber1();
         randomWinner2 = IAjiVRFv2Consumer(chainLink).RandomNumber2();
         randomWinner3 = IAjiVRFv2Consumer(chainLink).RandomNumber3();
        return ( randomWinner1, randomWinner2, randomWinner3);
     }

    function airdropRewardCalculation() external  returns(uint){
        Participant storage newParticipant = participants[msg.sender];
        require(gottenRaffelnum[msg.sender], "You do not qualify for reward");
        uint reward = newParticipant.points * 100000;
        newParticipant.points = 0;
        newParticipant.reward += reward;
        return(reward) ;          
    }

    function claimReward() external returns(string memory status){
        // require(block.timestamp > deadline, "not yet time to claim yet");
        Participant storage newParticipant = participants[msg.sender];
        require(gottenRaffelnum[msg.sender], "You do not qualify for reward");
        
        if(airDropRaffelNumber[msg.sender] == randomWinner1){
        
        require(newParticipant.reward > 0, "Reward Claimed");


        uint amount = newParticipant.reward;
        newParticipant.reward = 0;

        IERC20(ajidokwuToken).transfer(msg.sender, amount);
        emit rewardClaimed(msg.sender, "claimed", amount, "successfully");
        return ("CONGRATULATIONS");
        }
        else if(airDropRaffelNumber[msg.sender] == randomWinner2){
        
        require(newParticipant.reward > 0, "Reward Claimed");


        uint amount = newParticipant.reward;
        newParticipant.reward = 0;

        IERC20(ajidokwuToken).transfer(msg.sender, amount);
        emit rewardClaimed(msg.sender, "claimed", amount, "successfully");
        return ("CONGRATULATIONS");
        }
        else if(airDropRaffelNumber[msg.sender] == randomWinner3){
        
        require(newParticipant.reward > 0, "Reward Claimed");


        uint amount = newParticipant.reward;
        newParticipant.reward = 0;

        IERC20(ajidokwuToken).transfer(msg.sender, amount);

        emit rewardClaimed(msg.sender, "claimed", amount, "successfully");
        return ("CONGRATULATIONS");

        }

        else{
            revert("try again NEXT TIME");
            
        }


    }

    function timeLeft() external  view returns(uint TimeLeftIs){
        require(deadline > block.timestamp, "TIME UP");
        uint tL = deadline - block.timestamp;
        return tL;
    }
}