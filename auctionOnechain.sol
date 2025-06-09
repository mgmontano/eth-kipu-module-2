// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Auction Contract - A decentralized auction system
/// @author Montaño Marcelo
/// @notice This contract implements a time-based auction with automatic bid extension
/// @dev Uses OpenZeppelin-style patterns for security and best practices
contract AuctionContract {
    
    /// @notice The owner of the auction contract who receives commissions
    address payable public owner;
    
    /// @notice Address of the current highest bidder
    address public higuestBidder;
    
    /// @notice The current highest bid amount
    uint public higuestPrice;

    /// @notice Initial starting price of the auction
    uint public initPrice;
    
    /// @notice Current price threshold for new bids
    uint public actualPrice;
    
    /// @notice Minimum increment required for each new bid
    uint public incrementOffer;
    
    /// @notice Timestamp when the auction started
    uint public dateStartAuction;
    
    /// @notice Timestamp when the auction ends
    uint public dateEndAuction;
    
    /// @notice Time extension added when bids are placed near auction end
    uint public timeExtention;

    /// @notice Flag indicating whether the auction has ended
    bool public endedAuction;
    
    /// @notice Commission percentage charged on losing bids (2%)
    uint constant public COMISSION = 2;

    /// @notice Mapping to track bid amounts for each address (for withdrawals)
    mapping (address => uint256) public bidsToReturn;

    /// @notice Structure to store individual bid information
    /// @param bidder Address of the person placing the bid
    /// @param bid Amount of the bid in wei
    /// @param timeBid Timestamp when the bid was placed
    struct Bid {
        address bidder;
        uint bid;
        uint timeBid;
    }
    
    /// @notice Array storing all bids placed during the auction
    Bid[] public bids;

    /// @notice Initializes the auction contract with default parameters
    /// @dev Sets up initial auction parameters and assigns contract deployer as owner
    constructor() {
        owner = payable(msg.sender); 
        initPrice = 100000 gwei;
        actualPrice = initPrice;
        incrementOffer = (actualPrice / 100) * 5; // 5% increment
        dateStartAuction = block.timestamp;
        dateEndAuction = block.timestamp + 2 weeks;
        timeExtention = 10 minutes;
        endedAuction = false;
    }

    /// @notice Restricts function access to contract owner only
    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    /// @notice Emitted when a new bid is placed
    /// @param bidder Address of the bidder
    /// @param bidValue Amount of the bid in wei
    event newBid(address bidder, uint bidValue);

    /// @notice Emitted when the auction ends
    /// @param winner Address of the winning bidder
    /// @param actualPrice Final winning bid amount
    event auctionEnded(address winner, uint actualPrice);

    /// @notice Emitted when auction time is extended due to late bidding
    /// @param newEndTimeAuction New end timestamp for the auction
    event auctionExtended(uint newEndTimeAuction);

    /// @notice Places a bid in the auction
    /// @dev Validates bid amount, timing, and updates auction state accordingly
    /// @dev Automatically extends auction time if bid is placed within 10 minutes of end
    /// Requirements:
    /// - Bid must be higher than initial price
    /// - Bid must exceed current price plus minimum increment
    /// - Auction must be active (between start and end time)
    function bid() external payable {
        uint bidValue = msg.value;
        
        // Check if bid meets minimum requirements
        if (bidValue > initPrice) {
            require(bidValue > actualPrice, "The value of the offer must be higher than the current one.");
            require(bidValue > actualPrice + incrementOffer, "The value of the offer must be greater than the increase.");
            
            // Verify auction is currently active
            if ((block.timestamp < dateEndAuction) && (block.timestamp >= dateStartAuction)) {
                // Create new bid record
                Bid memory bidNew = Bid(msg.sender, msg.value, block.timestamp);
                actualPrice = bidValue;
                bidsToReturn[msg.sender] = bidValue;
                bids.push(bidNew);
                
                emit newBid(msg.sender, msg.value);
                
                // Update highest bidder information
                higuestBidder = msg.sender;
                higuestPrice = msg.value;

                // Extend auction time if bid placed within 10 minutes of end
                if (block.timestamp >= dateEndAuction - 10 minutes) {
                    dateEndAuction = dateEndAuction + 10 minutes;
                    emit auctionExtended(dateEndAuction);
                }   
            }
        }
    } 

    /// @notice Manually ends the auction if time has expired
    /// @dev Can be called by anyone once the auction end time has passed
    /// @dev Sets endedAuction flag to true and emits auctionEnded event
    function endAuction() external {
        if (block.timestamp >= dateEndAuction) {
            endedAuction = true;
            emit auctionEnded(higuestBidder, higuestPrice);
        } 
    }

    /// @notice Returns the winner and winning bid amount
    /// @dev Only returns valid data after auction has ended
    /// @return winnerAuction_ Address of the auction winner
    /// @return winningBid_ Amount of the winning bid in wei
    function showWinnerAuction() external view returns (address winnerAuction_, uint winningBid_) {
        if (endedAuction) {
            return (higuestBidder, higuestPrice);
        } 
    }

    /// @notice Returns all bids placed during the auction
    /// @dev Provides complete bidding history for transparency
    /// @return allBids_ Array containing all bid structures
    function showBids() external view returns (Bid[] memory allBids_) {
        return bids;
    }

    /// @notice Allows losing bidders to withdraw their funds after auction ends
    /// @dev Automatically deducts commission and transfers remainder to bidders
    /// @dev Only processes withdrawals for non-winning bidders after auction completion
    /// @dev Owner receives commission from each losing bid
    /// Requirements:
    /// - Auction must have ended
    /// - Only processes losing bidders (not the winner)
    function withdraw() external {
        uint amountComission = 0;
        
        if (endedAuction) {
            // Process all bids for withdrawal
            for (uint i = 0; i < bids.length; i++) {
                // Skip the winning bidder
                if (bids[i].bidder != higuestBidder) {
                    // Calculate commission (2% of bid amount)
                    amountComission = (bidsToReturn[bids[i].bidder] / 100 * COMISSION);
                    
                    // Calculate withdrawal amount after commission
                    uint256 withdrawAmount = bidsToReturn[bids[i].bidder] - amountComission;
                    
                    // Transfer commission to owner
                    payable(owner).transfer(amountComission);
                    
                    // Transfer remaining amount to bidder
                    payable(bids[i].bidder).transfer(withdrawAmount);
                }
            }
        }
    }
}
