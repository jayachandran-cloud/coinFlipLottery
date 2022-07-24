<h3> Project Title </h3>
# coinFlipLottery

<h3> Problem Statement </h3>
 https://trigon.notion.site/Web3-Solidity-Challenge-Coin-Flip-d6f6e38c664a4d68bc03615c1009cb0f
 
 <h3>sample Transactions </h3>
 <h4>contract link</h4>
 https://rinkeby.etherscan.io/address/0x46c57c5783a0a54e00b865a39958eaea277d1228
 <h4>lottery deployment </h4>
 https://rinkeby.etherscan.io/tx/0xf2448c660118f999ecf7012d1586bb9a6aed54d772e5f82799f2221b6b67202b
 <h4> enter lottery (players betting in lottery)</h4>
 https://rinkeby.etherscan.io/tx/0xddf59664008dab0f97506f026f6fd6db0243cb0bc815a962a839e0b384d8097d
 https://rinkeby.etherscan.io/tx/0x5e765b8a58424879a95ce4aef3190fc70266b9cfd32f4ac15720d609ef073d2f
 https://rinkeby.etherscan.io/tx/0xc925998ab816997eac0e15541bb75ee84700d0d99b40eedd8be99868dc9d460d
 https://rinkeby.etherscan.io/tx/0x30b5fe55826ddcc1d9a340de9813bc8c961b579d86fc9e891d9bf24b439f4738
 <h4> pick winner (by admin )(VRF number generation is called internally)
 https://rinkeby.etherscan.io/tx/0xfa4e6cb711435985a2b9199588e624792a3a0d8189403a2095c60f591c65696e
 
 <h3> code explanation </h3>
 
 <p>The details (players address,is he already voted(IsInLotterypool),bettingNumber(0 or 1),amount(thst he wanted to bet on that number),is the joining balance(100 points) creditted or not ) are stored  in a array of structure(for each player) and mapped to their addresses (for accessing each players details)</p>
  <p>and then the whole structure is mapped to completed bets on completion of each bet .then the structure is resetted to default.</p>
  <p>The balance of the player is mapped seperately as given in the problem statement(if we stored the balance in the structure ,it will go back to default on completion of each bet(we don't need it because on completion of each lottery someone wins/losses ,so their balance needs to be stored seperately)</p>
 <br>
![struct](https://user-images.githubusercontent.com/79778475/180630599-7dc0f7bc-8cd5-46bd-9619-dd768416d2aa.png)
<br>
  <p>As giveen in the problem statement players can bet their amount on their preferred number(0 or 1) by calling enterLottery() function <p>
  <p>After a while the Admin(the one who deploys the contract) of the lottery calls pickWinner(), then it does call random number generation function(it generates random number) , the random number generator calls the rewardBet() function (which chooses the winners ,rewards them ,mappes this lottery to completedBets and resets the array of structure)<p>
  <p>and the players can withdraw their points into ether(1point ==0.001eth),and they can deposit ether to add more points for betting<p>
  <p>if a lot of people wins the lottery we must pay them more then the income ,so a minimum amount of 0.01eth must be sent to the contract when we deploy it(in worst case every one in the lottery wins means,we must pay double the amount ,so we must have balance in our contract to pay them)</p>
