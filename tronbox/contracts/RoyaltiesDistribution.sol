// SPDX-License-Identifier: MIT
/*
1) Add shareholder addresses
2) Remove shareholders addresses
3) Modify shares weight for each shareholder
4) Distribute USDT depending on each shareholder shares
5) Modify TRC20 token contract address
*/
pragma solidity ^0.8.20;

interface ITRC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract RoyaltiesDistribution {
    struct Payee {
        //Shareholder
        address account;
        uint256 share;
    }

    address public owner;
    ITRC20 public usdtToken;
    Payee[] public payees;
    uint256 public totalShares;

    event PayeeAdded(address account, uint256 share);
    event PayeeRemoved(address account);
    event RoyaltiesDistributed(uint256 amount);
    event DistributionFailed(address account, uint256 amount);
    event TokenContractUpdated(address newTokenContract);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner may call function");
        _;
    }

    constructor(address _usdtToken) {
        owner = msg.sender;
        usdtToken = ITRC20(_usdtToken);
        totalShares = 0;
    }

    /**
     * @notice Adds a new payee with a specified share
     * @param account Address of new payee
     * @param share Number of shares
     */
    function addPayee(address account, uint256 share) external onlyOwner {
        require(account != address(0), "Account is the zero address"); //This helps to protect users from adding the 0 address (burn address)
        require(share > 0, "Share must be greater than zero");
        payees.push(Payee(account, share));
        totalShares = totalShares + share;
        emit PayeeAdded(account, share);
    }

    /**
     * @notice Removes an existing payee
     * @param account Address of payee to remove
     */
    function removePayee(address account) external onlyOwner {
        require(account != address(0), "Account is the zero address");

        for (uint256 i = 0; i < payees.length; i++) {
            if (payees[i].account == account) {
                totalShares = totalShares - payees[i].share; //Deduct the to be removed account shares from the total shares

                // Swap with the last element and pop
                payees[i] = payees[payees.length - 1];
                payees.pop();

                emit PayeeRemoved(account);
                break;
            }
        }
    }

    /**
     * @notice Updates the token contract address for distribution
     * @param newTokenContract Address of new token for this contract to distribute
     */
    function updateTokenContract(address newTokenContract) external onlyOwner {
        require(
            newTokenContract != address(0),
            "New token contract is the zero address"
        );
        usdtToken = ITRC20(newTokenContract);
        emit TokenContractUpdated(newTokenContract);
    }

    /**
     * @notice Distributes royalties to all payees based on their shares
     */
    function distributeRoyalties() external onlyOwner {
        require(totalShares > 0, "No shares defined");
        uint256 totalAmount = usdtToken.balanceOf(address(this));
        require(totalAmount > 0, "No USDT to distribute");

        for (uint256 i = 0; i < payees.length; i++) {
            Payee memory payee = payees[i];
            uint256 payment = (totalAmount * payee.share) / totalShares;
            bool success = usdtToken.transfer(payee.account, payment);

            if (!success) {
                emit DistributionFailed(payee.account, payment);
                revert("USDT transfer failed");
            }
        }

        emit RoyaltiesDistributed(totalAmount);
    }
}
