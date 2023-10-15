pragma solidity ^0.8.0;

contract Token {
    string public name = "GamerXGold";
    string public symbol = "GXG";
    uint256 public totalSupply = 1000000;
    address public owner;
    mapping(address => uint256) balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    // New state variables for betting
    uint256 public pot;
    uint256 public minimumBet = 10; // Minimum bet in tokens
    uint256 public feePercentage = 2; // 2% fee
    uint256 public donationPercentage = 5; // 5% donation
    
    // Addresses for fee and donation
    address public feeAddress;
    address public donationAddress;

    // Events for betting
    event BetPlaced(address indexed _player, uint256 _betAmount, uint256 _score, string _message);
    event BetResult(address indexed _winner, uint256 _amountWon);

    constructor(address _feeAddress, address _donationAddress) {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        feeAddress = _feeAddress;
        donationAddress = _donationAddress;
    }

    function transfer(address to, uint256 amount) external {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    // Function to place a bet
    function placeBet(uint256 betAmount, uint256 playerScore, string memory message) external {
        require(betAmount >= minimumBet, "Bet amount is below the minimum bet");
        require(balances[msg.sender] >= betAmount, "Not enough tokens to place the bet");

        // Calculate the fee and donation amounts
        uint256 feeAmount = (betAmount * feePercentage) / 100;
        uint256 donationAmount = (betAmount * donationPercentage) / 100;

        // Deduct the fee and donation amounts from the bet amount
        uint256 actualBetAmount = betAmount - feeAmount - donationAmount;

        // Deduct the bet amount from the player's balance and add it to the pot
        balances[msg.sender] -= betAmount;
        pot += actualBetAmount;

        // Send the fee to the fee address
        balances[feeAddress] += feeAmount;

        // Send the donation to the donation address
        balances[donationAddress] += donationAmount;

        emit BetPlaced(msg.sender, actualBetAmount, playerScore, message);
    }

    // Modifier to restrict access to the resolveBet function
    modifier onlyResolver() {
        require(msg.sender == owner, "Only the owner can resolve bets");
        _;
    }

    // Function to resolve a bet and determine the winner
    function resolveBet(address player1, uint256 score1, address player2, uint256 score2) external onlyResolver {
        // Check that the scores are provided by valid players
        require(balances[player1] > 0 && balances[player2] > 0, "Invalid players");

        if (score1 > score2) {
            // Player1 wins
            balances[player1] += pot;
            emit BetResult(player1, pot);
        } else if (score2 > score1) {
            // Player2 wins
            balances[player2] += pot;
            emit BetResult(player2, pot);
        } else {
            // It's a draw; return the bet amounts to the players
            balances[player1] += pot / 2;
            balances[player2] += pot / 2;
            emit BetResult(address(0), pot); // Address(0) represents a draw
        }

        // Reset the pot
        pot = 0;
    }
}
