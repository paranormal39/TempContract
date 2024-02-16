// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScoreBet {
    address public player1;
    address public player2;
    uint256 public player1Score;
    uint256 public player2Score;
    address public winner;
    bool public gameStarted;
    bool public gameEnded;
    address public owner;

    event GameStarted();
    event GameEnded(address winner, uint256 player1Score, uint256 player2Score);
    event PlayerJoined(address player);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyPlayers() {
        require(msg.sender == player1 || msg.sender == player2, "You are not part of the game");
        _;
    }

    modifier gameNotEnded() {
        require(!gameEnded, "Game has already ended");
        _;
    }

    modifier gameNotStarted() {
        require(!gameStarted, "Game has already started");
        _;
    }
    modifier GameEndedModifier() {
    require(gameEnded, "Game has not ended yet");
    _;
}


    constructor() {
        owner = msg.sender;
    }

    function joinGame() external gameNotStarted {
        require(player1 != msg.sender && player2 != msg.sender, "You are already part of the game");

        if (player1 == address(0)) {
            player1 = msg.sender;
        } else if (player2 == address(0)) {
            player2 = msg.sender;
        }

        emit PlayerJoined(msg.sender);

        // If both players have joined, start the game automatically
        if (player1 != address(0) && player2 != address(0)) {
            startGame();
        }
    }

    function startGame() internal gameNotStarted {
        gameStarted = true;
        emit GameStarted();
    }

    function submitScore(uint256 _score) external onlyPlayers gameNotEnded GameEndedModifier{
        if (msg.sender == player1) {
            player1Score = _score;
        } else {
            player2Score = _score;

            // Check if both players have submitted their scores
            if (player1Score != 0) {
                endGame();
            }
        }
    }

    function endGame() internal GameEndedModifier {
        require(player1Score != 0 && player2Score != 0, "Both players must submit scores");

        if (player1Score > player2Score) {
            winner = player1;
        } else {
            winner = player2;
        }

        gameEnded = true;
        emit GameEnded(winner, player1Score, player2Score);
    }

    function withdrawWinnings() external GameEndedModifier {
        require(msg.sender == winner, "You are not the winner");
        // Implement the logic to transfer winnings to the winner
        // Example: payable(winner).transfer(address(this).balance);
        payable(winner).transfer(address(this).balance);
    }
}
