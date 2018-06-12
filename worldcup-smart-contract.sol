pragma solidity ^0.4.0;
contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract  worldcup2018 is owned
{
    //to keep coding simple, leave 0 index as unused;
    mapping(address => uint256)[33]  public userBetMultipliedAmountForTeam;
    uint256 public totalAmountForBets;
	uint256[33]  public  totalBetMultipliedAmountForTeam;
    bool public  isBetClosed;
    uint  public championTeamId;
    uint  public multiplier;  // it actually meanns:how many teams are posssible champion.
    uint  public worldcupYear = 2018;
    uint  public firstRankingTeamId = 21;  //that is German team, who is ranking #1 in FIFA
    
    event NEWBET(address sender, uint value, uint teamId);
    event BONUSSENT(address sender, uint bonus);
    
    function worldcup2018() public
    {
        isBetClosed = false;
        championTeamId = 0;
        multiplier = 32;
    }
    
    function () payable public{
        ///and Qtum sending to contract, will be regarded as betting first Ranking Team
        betChampionTeam(firstRankingTeamId);
    }
    function betChampionTeam(uint teamId) payable public
    {
        //valid teamId should be 1~32
        require(teamId > 0);
        require(teamId < 33);
        require(!isBetClosed);
        
        totalAmountForBets += msg.value;
        userBetMultipliedAmountForTeam[teamId][msg.sender] += (msg.value * multiplier);
        totalBetMultipliedAmountForTeam[teamId] += (msg.value * multiplier);
        NEWBET(msg.sender, msg.value, teamId);
        
    }
    function setMultiplier (uint newMultiplier) public onlyOwner
    {
        require(newMultiplier > 1);
        require(newMultiplier < multiplier);
        multiplier = newMultiplier;
    }
    function setBetClosed() public onlyOwner
    {
        isBetClosed = true;
    }
    function setChampionTeam(uint teamId) public onlyOwner
    {
        require(teamId > 0);
        require(teamId < 33);
        championTeamId = teamId;
    }
    function claimWinBonus()  public
    {
        require(championTeamId > 0);
        uint multipliedAmount = userBetMultipliedAmountForTeam[championTeamId][msg.sender];
        if(multipliedAmount > 0)
        {
            userBetMultipliedAmountForTeam[championTeamId][msg.sender] = 0;
            uint bonusAmount = multipliedAmount * totalAmountForBets / totalBetMultipliedAmountForTeam[championTeamId];
            if(!msg.sender.send(bonusAmount))
			{
			    //send error, restore it.
                userBetMultipliedAmountForTeam[championTeamId][msg.sender] = multipliedAmount;
                
			}
			else
			{
			    BONUSSENT(msg.sender, bonusAmount);
			}

        }
        
    }

}
