// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITRC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract RoyaltiesDistribution {
    struct Payee {
        address account;
        uint256 score;          // User's test score
        uint256 stakeAmount;    // Amount bet by the user (usually 100 USDT)
        uint256 lastPayoutClaimed; // Timestamp of the last payout claimed
    }

    address public owner;
    ITRC20 public usdtToken;
    Payee[] public payees;
    uint256 public totalBetAmount;  // Total USDT in the betting pool
    uint256 public totalScores;     // Sum of all users' test scores

    event PayeeAdded(address account, uint256 score);
    event PayoutClaimed(address user, uint256 amount);
    event Stake(address user, uint256 amount);
    event BettingClosed();

    bool public bettingPhaseActive = true;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner may call function");
        _;
    }

    modifier onlyDuringBetting() {
        require(bettingPhaseActive, "Betting phase is closed");
        _;
    }

    constructor(address _usdtToken) {
        owner = msg.sender;
        usdtToken = ITRC20(_usdtToken);
        totalBetAmount = 0;
        totalScores = 0;
    }

    /**
     * @notice Each user bets a fixed amount (100 USDT) to join.
     */
    function bet(uint256 score) external onlyDuringBetting {
        uint256 bettingAmount = 100 * 1e6; // Assuming USDT has 6 decimals
        require(
            usdtToken.transferFrom(msg.sender, address(this), bettingAmount),
            "Bet transfer failed"
        );

        // Add the user and their score to the payees array
        payees.push(Payee(msg.sender, score, bettingAmount, 0));

        // Increase total betting pool and total scores
        totalBetAmount += bettingAmount;
        totalScores += score;

        emit Stake(msg.sender, bettingAmount);
    }

    /**
     * @notice Ends the betting phase, disallowing further bets.
     */
    function closeBettingPhase() external onlyOwner onlyDuringBetting {
        bettingPhaseActive = false;
        emit BettingClosed();
    }

    /**
     * @notice Calculate each user's payout based on the formula:
     * (totalBetAmount / totalScores) * (userScore / 100) * bettingAmount
     * This can be claimed after the exam.
     */
    function claimPayout() external {
        require(!bettingPhaseActive, "Betting phase must be closed before claiming payout");

        for (uint256 i = 0; i < payees.length; i++) {
            if (payees[i].account == msg.sender) {
                require(payees[i].lastPayoutClaimed == 0, "Payout already claimed");

                uint256 userScore = payees[i].score;
                uint256 userStake = payees[i].stakeAmount;

                // Formula to calculate payout
                uint256 payout = (totalBetAmount * userScore / totalScores) * userStake / (100 * 1e6); // 100 is a percentage base
                require(payout > 0, "No payout available");

                // Mark the payout as claimed
                payees[i].lastPayoutClaimed = block.timestamp;

                // Transfer the payout
                usdtToken.transfer(msg.sender, payout);
                emit PayoutClaimed(msg.sender, payout);
                return;
            }
        }

        revert("User not found or payout already claimed");
    }

    /**
     * @notice Returns the total USDT in the betting pool.
     */
    function getPoolSize() external view returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }

    /**
     * @notice Returns the total of all users' test scores.
     */
    function getTotalScores() external view returns (uint256) {
        return totalScores;
    }

    /**
     * @notice Returns the stake of a specific user.
     * @param user Address of the user
     */
    function getUserStake(address user) external view returns (uint256) {
        for (uint256 i = 0; i < payees.length; i++) {
            if (payees[i].account == user) {
                return payees[i].stakeAmount;
            }
        }
        return 0; // If no stake found for the user
    }

    /**
     * @notice Returns the score of a specific user.
     * @param user Address of the user
     */
    function getUserScore(address user) external view returns (uint256) {
        for (uint256 i = 0; i < payees.length; i++) {
            if (payees[i].account == user) {
                return payees[i].score;
            }
        }
        return 0; // If no score found for the user
    }
}