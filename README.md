# Auction Contract 🔨

A decentralized auction smart contract built on Ethereum that implements a time-based bidding system with automatic time extensions and commission-based withdrawals.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Contract Details](#contract-details)
- [Installation](#installation)
- [Usage](#usage)
- [Functions](#functions)
- [Events](#events)
- [Security Features](#security-features)
- [Gas Optimization](#gas-optimization)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

The Auction Contract is a Solidity smart contract that facilitates decentralized auctions on the Ethereum blockchain. It features automatic bid validation, time extensions for last-minute bids, and a commission system for the auction house.

### Key Highlights
- **Time-based auctions** with automatic extension mechanism
- **Commission system** (2%) on losing bids
- **Bid validation** with minimum increment requirements
- **Transparent bidding history** with complete audit trail
- **Secure withdrawal system** for non-winning bidders

## ✨ Features

- ⏰ **Automatic Time Extension**: Extends auction by 10 minutes if bids are placed within the last 10 minutes
- 💰 **Commission System**: 2% commission charged on losing bids
- 🔒 **Access Control**: Owner-only functions for contract management
- 📊 **Bid Tracking**: Complete history of all bids with timestamps
- 💸 **Secure Withdrawals**: Automated refund system for losing bidders
- 🎯 **Minimum Increment**: 5% minimum bid increment requirement

## 📄 Contract Details

| Parameter | Value | Description |
|-----------|-------|-------------|
| **Initial Price** | 100,000 gwei | Starting bid amount |
| **Auction Duration** | 2 weeks | Default auction length |
| **Time Extension** | 10 minutes | Added when late bids occur |
| **Minimum Increment** | 5% | Required bid increase |
| **Commission Rate** | 2% | Fee on losing bids |
| **Solidity Version** | ^0.8.19 | Compiler version |

## 🚀 Installation

### Prerequisites
- Node.js (v14+)
- Hardhat or Truffle
- MetaMask or similar Web3 wallet

### Setup
```bash
# Clone the repository
git clone https://github.com/your-username/auction-contract.git
cd auction-contract

# Install dependencies
npm install

# Compile contracts
npx hardhat compile
```

## 💡 Usage

### Deploying the Contract
```javascript
// Deploy script example
const AuctionContract = await ethers.getContractFactory("AuctionContract");
const auction = await AuctionContract.deploy();
await auction.deployed();
console.log("Auction deployed to:", auction.address);
```

### Interacting with the Contract
```javascript
// Place a bid
await auction.bid({ value: ethers.utils.parseEther("0.1") });

// Check auction winner
const [winner, amount] = await auction.showWinnerAuction();

// Withdraw funds (for losing bidders)
await auction.withdraw();
```

## 🔧 Functions

### Public Functions

#### `bid()`
Places a bid in the auction.
- **Payable**: Yes
- **Requirements**: 
  - Bid must exceed current price + minimum increment
  - Auction must be active
  - Must be higher than initial price

#### `endAuction()`
Manually ends the auction after time expires.
- **Access**: Public
- **Requirements**: Current time must be past auction end time

#### `showWinnerAuction()` → `(address, uint)`
Returns the auction winner and winning bid amount.
- **View Function**: Yes
- **Returns**: Winner address and bid amount
- **Requirements**: Auction must have ended

#### `showBids()` → `Bid[]`
Returns complete bidding history.
- **View Function**: Yes
- **Returns**: Array of all bid structures

#### `withdraw()`
Processes withdrawals for losing bidders.
- **Access**: Public
- **Requirements**: Auction must have ended
- **Note**: Automatically deducts 2% commission

### State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `owner` | `address payable` | Contract owner (receives commissions) |
| `higuestBidder` | `address` | Current highest bidder |
| `higuestPrice` | `uint` | Current highest bid amount |
| `initPrice` | `uint` | Initial auction price |
| `actualPrice` | `uint` | Current minimum bid threshold |
| `incrementOffer` | `uint` | Minimum bid increment (5% of current price) |
| `dateStartAuction` | `uint` | Auction start timestamp |
| `dateEndAuction` | `uint` | Auction end timestamp |
| `endedAuction` | `bool` | Auction status flag |
| `COMISSION` | `uint constant` | Commission rate (2%) |

## 📡 Events

### `newBid(address bidder, uint bidValue)`
Emitted when a new bid is placed.
- **Parameters**:
  - `bidder`: Address of the bidder
  - `bidValue`: Amount of the bid in wei

### `auctionEnded(address winner, uint actualPrice)`
Emitted when the auction concludes.
- **Parameters**:
  - `winner`: Address of the winning bidder
  - `actualPrice`: Final winning bid amount

### `auctionExtended(uint newEndTimeAuction)`
Emitted when auction time is extended.
- **Parameters**:
  - `newEndTimeAuction`: New auction end timestamp

## 🔐 Security Features

- **Reentrancy Protection**: Uses checks-effects-interactions pattern
- **Access Control**: Owner-only modifier for sensitive functions  
- **Input Validation**: Comprehensive bid validation logic
- **Timestamp Dependency**: Minimal reliance on block.timestamp
- **Integer Overflow**: Protected by Solidity ^0.8.19 built-in checks

## ⚡ Gas Optimization

- Efficient storage patterns
- Minimal external calls
- Optimized loop structures in withdrawal function
- Strategic use of memory vs storage

## 🧪 Testing

```bash
# Run tests
npx hardhat test

# Run with coverage
npx hardhat coverage

# Run specific test file
npx hardhat test test/AuctionContract.test.js
```

### Test Coverage
- ✅ Bid placement and validation
- ✅ Time extension mechanism
- ✅ Auction ending logic
- ✅ Withdrawal system
- ✅ Event emission
- ✅ Access control

## 🚀 Deployment

### Testnet Deployment
```bash
# Deploy to Goerli testnet
npx hardhat run scripts/deploy.js --network goerli

# Verify contract
npx hardhat verify --network goerli DEPLOYED_CONTRACT_ADDRESS
```

### Mainnet Deployment
```bash
# Deploy to Ethereum mainnet
npx hardhat run scripts/deploy.js --network mainnet
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Solidity style guide
- Add comprehensive tests for new features
- Update documentation for any changes
- Ensure gas optimization

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you have questions or need help:
- Create an issue on GitHub
- Contact: montano.marcelo@example.com
- Documentation: [Project Wiki](https://github.com/your-username/auction-contract/wiki)

## 🔍 Audit Status

⚠️ **This contract has not been professionally audited. Use at your own risk in production environments.**

For production use, consider:
- Professional security audit
- Extensive testing on testnets
- Bug bounty program
- Gradual rollout with monitoring

---

**Built with ❤️ by Montaño Marcelo**
