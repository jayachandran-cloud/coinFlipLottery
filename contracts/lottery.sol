// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

//import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract enterLottery is VRFConsumerBase{
    //declaring structure of player 
    struct player  {
        bool IsInLotteryPool;  
        uint256 betingNum;
        uint256 amount;
        address playerAddress;
        bool BalanceCredited;
    }
    //admin variable
    address payable public immutable i_admin;
    //array of structure and mappings to player and balance
    player[]   Players;
    mapping (address => player) public Playermap;
    mapping(address => uint256) private BalanceOfPlayer;
    //mapping for completed bets
    mapping(uint256 => player[]) public completedBets;
    uint256 completedBetCount;
    //event for emitting winner 
    event Winner(address winner,uint256 Amount);

    bytes32 internal keyHash; // identifies which Chainlink oracle we use
    uint internal fee;        // fee to get random number
    uint public randomResult;


    constructor () VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF coordinator  
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK token address 
        ) payable
        {
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; 
        fee = 0.1 * 10 ** 18;    // 0.1 LINK

        //initialising admin
        i_admin = payable(msg.sender);
        BalanceOfPlayer[msg.sender] = 10000;
        //initialising contract balance
        (bool success,)= msg.sender.call{value:0.01*1e18}("");
        require(success,"can't sent eth");
        BalanceOfPlayer[address(this)] = 1000;
    }
    
  
     function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in contract");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint randomness) internal override {
        randomResult = randomness;
        rewardsBet();
    }
    
    function getBalance(address _playerAddress) public view returns(uint256 balance){
        if(msg.sender==_playerAddress){
            return BalanceOfPlayer[_playerAddress];
        }
    }
    //cheching and initialising player balance 
    function IsBalancecreditted()private returns(bool){
        if(Playermap[msg.sender].BalanceCredited ==false){
            BalanceOfPlayer[msg.sender]=100;
            Playermap[msg.sender].BalanceCredited=true;
            }
            return Playermap[msg.sender].BalanceCredited;
    }

    //betting lottery function  // _betNum={0,1}  , amount =the amount that you want to bet
    function enterLotery(uint256 _betNum,uint256 _amount)public {
        //checks is the player already in lottery
        require(
            !Playermap[msg.sender].IsInLotteryPool,
            "The player already is in lottery"
        );

        //checks the betting no and amount
        //gathering and storing the player details in array and mapping 
        player memory playerPusher=player(
            {
                IsInLotteryPool:true,
                betingNum:_betNum,
                amount:_amount,
                playerAddress:msg.sender,
                BalanceCredited:IsBalancecreditted()
            });
        require(_betNum==0 || _betNum==1 , "enter valid betting");
        require(_amount > 0 && _amount <= BalanceOfPlayer[msg.sender],"check the bet amount");
        Players.push(playerPusher);
        Playermap[msg.sender]=playerPusher;
        ////detecting the players balance and adding it to admin balance
        BalanceOfPlayer[msg.sender] -= _amount;
        BalanceOfPlayer[i_admin]+=_amount;
    }

    // function getRandomNumber1() public view returns (uint) {
    //     return uint(keccak256(abi.encodePacked(i_admin, block.timestamp)));
    // }
    function pickWinner() public adminOnly{
        getRandomNumber();
    }

    //rewardbet function chooses the winner 
    function rewardsBet() internal {  
        //getting random number and deciding winning number
        uint256 winningNo = randomResult % 2;
        //traversing through the array and adding the doubled amount of their bet to the winners
        for(uint256 index=0; index < Players.length ; index++){

            if(Players[index].betingNum==winningNo){
                uint256 amount=Players[index].amount*2;
                BalanceOfPlayer[Players[index].playerAddress]+=amount;
                BalanceOfPlayer[i_admin]-=amount;
                //emitting  Winners event
                emit Winner(
                    Players[index].playerAddress,
                    Players[index].amount
                    );
                
            }
            //getting the players out of lottery //now they can start betting again 
            Players[index].IsInLotteryPool=false;
        }
        //mapping to completed bets
        completedBets[completedBetCount]=Players;
        completedBetCount++;
        //resetting the array of structure
        delete Players;
    }
    //player can withdraw the equivalant amount of ether(1pt=0.001eth) from their account 
    function withdraw(uint withdrawAmount) public returns (uint remainingBal) {
        // Check enough balance available, otherwise just return balance
        if (withdrawAmount <= BalanceOfPlayer[msg.sender]) {
            (bool success,)= msg.sender.call{value:withdrawAmount*1e15}("");
            require(success," can't withdraw ");
            BalanceOfPlayer[msg.sender] -= withdrawAmount;
        }
        return BalanceOfPlayer[msg.sender];
    }
    //player can deposit ether (ether will be converted to its equivalent(0.001eth=1pt) points and added to their account balance) 
    function deposit() public payable returns (uint256){
        require(msg.value> 0.001*1e18,"not enough eth");
        BalanceOfPlayer[msg.sender]+=msg.value/1e15;
        return msg.value/1e15;
    }

     modifier adminOnly() {
        require(msg.sender == i_admin, "Not admin");   
        _;
    }
}